module Oldsys = Sys

open Lwt
open Printf
open Core.Std

let make_issue user repo token dir issue =
  let open Github.Monad in
  let open Github_t in
  let filename = Filename.concat dir (string_of_int issue.issue_number) in
  Out_channel.with_file filename ~f:( fun file ->
    printf "Creating issue %d\n" issue.issue_number;
    let labels = (List.map ~f:(fun l -> l.label_name) issue.issue_labels) in
    fprintf file "%s\nopened on ... by %s\ntags: %s\n\n%s"
      issue.issue_title issue.issue_user.user_login
      (String.concat ~sep:" " labels) issue.issue_body
  )

let make_milestone user repo token out milestone =
  let open Github.Monad in
  let open Github_t in
  let dir = Filename.concat out milestone.milestone_title in
  let filter = `Num milestone.milestone_number in
  if Oldsys.file_exists dir then () else Unix.mkdir dir;
  run (Github.Issue.for_repo ~token ~user ~repo ~milestone:filter ()
       >>= (fun issues ->
         printf "Issues: %d\n%!" (List.length issues);
         return (List.iter ~f:(make_issue user repo token dir) issues))); ()

let write user repo token out =
  let open Github.Monad in
  let open Github_t in
  if Oldsys.file_exists out then () else Unix.mkdir out;
  run (Github.Milestone.for_repo ~token ~user ~repo ()
       >>= (fun milestones ->
         return (List.iter ~f:(make_milestone user repo token out) milestones)))

let read_git_config value =
  let buffer_size = 128 in
  let buffer = Buffer.create buffer_size in
  let string = String.create buffer_size in
  let command = "git config --global --get " ^ value in
  let in_channel = Unix.open_process_in command in
  let chars_read = ref 1 in
  while !chars_read <> 0 do
    chars_read := input in_channel string 0 buffer_size;
    Buffer.add_substring buffer string 0 !chars_read
  done;
  ignore (Unix.close_process_in in_channel);
  let out = Buffer.contents buffer in
  String.sub out 0 ((String.length out) - 1)

let _ = match Sys.argv |> Array.to_list |> List.tl with
  | Some [user_repo; out] ->
    (match Str.split (Str.regexp "/") user_repo with
      | [user; repo] ->
        let token = read_git_config "github.oauth-token" in
        Lwt_main.run (write user repo (Github.Token.of_string token) out)
      | _ -> printf("Usage: edgestow USER/REPO OUT_DIR\n"); exit 1)
  | _ -> printf("Usage: edgestow USER/REPO OUT_DIR\n"); exit 1
