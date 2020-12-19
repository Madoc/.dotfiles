use crate::check_directory::Directory;
use crate::check_directory::Directory::{ConfigDirectory, HomeDirectory};
use std::env::args;
use std::process::exit;

mod check_directory;
mod list_directory;
mod read_config;

fn main() {
  let argv: Vec<String> = args().collect();
  if argv.len() != 2 {
    print_usage(argv);
    exit(1);
  }
  match read_config::read_config(argv.get(1).unwrap()).and_then(run) {
    Ok(_) => (),
    Err(err) => {
      eprintln!("{}", err);
      exit(1);
    }
  }
}

fn run(whitelist: Vec<String>) -> Result<(), String> {
  run_directory(HomeDirectory, &whitelist).and_then(|_| run_directory(ConfigDirectory, &whitelist))
}

fn run_directory(directory: Directory, whitelist: &Vec<String>) -> Result<(), String> {
  check_directory::check_directory(directory, whitelist)
    .map(|msg_opt| msg_opt.iter().for_each(|msg| println!("{}\n", msg)))
}

fn print_usage(argv: Vec<String>) {
  eprintln!(
    "Usage: {} config_file",
    argv.get(0).unwrap_or(&"check_dotfiles".to_string())
  );
}
