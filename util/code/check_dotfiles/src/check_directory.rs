use crate::list_directory::list_directory;
use std::env::var;

#[derive(Clone, Copy)]
pub enum Directory {
  ConfigDirectory,
  HomeDirectory,
  #[allow(dead_code)]
  TestDirectory,
}

#[test]
fn test() {
  assert_eq!(
    check_directory(
      Directory::TestDirectory,
      &vec![".dotfile".to_string(), "test.txt".to_string()]
    ),
    Ok(None)
  );
  assert_eq!(
    check_directory(Directory::TestDirectory, &vec!["test.txt".to_string()]),
    Ok(Some("Unexpected in test_data/test_directory: '.dotfile'".to_string()))
  );
  assert_eq!(
    check_directory(Directory::TestDirectory, &vec![]),
    Ok(Some(
      "Unexpected in test_data/test_directory: '.dotfile', 'test.txt'".to_string()
    ))
  );
}

pub fn check_directory(directory: Directory, whitelist: &Vec<String>) -> Result<Option<String>, String> {
  dir_path(directory)
    .and_then(|path| list_directory(&path))
    .map(|contents| check(contents, directory, whitelist))
}

fn check(contents: Vec<String>, directory: Directory, whitelist: &Vec<String>) -> Option<String> {
  let mut unexpected_files: Vec<String> = Vec::new();
  for file in contents {
    if !is_allowed(&file, directory, whitelist) {
      unexpected_files.push(file);
    }
  }
  if unexpected_files.is_empty() {
    None
  } else {
    unexpected_files.sort();
    Some(format!(
      "Unexpected in {}: {}",
      dir_name(directory),
      unexpected_files
        .iter()
        .map(|file| format!("'{}'", file))
        .collect::<Vec<_>>()
        .join(", ")
    ))
  }
}

fn is_allowed(file_name: &str, directory: Directory, whitelist: &Vec<String>) -> bool {
  let whitelist_entry: String = match directory {
    Directory::ConfigDirectory => format!(".config/{}", file_name),
    Directory::HomeDirectory | Directory::TestDirectory => file_name.to_string(),
  };
  whitelist.binary_search(&whitelist_entry.to_string()).is_ok() || is_allowed_for_directory(file_name, directory)
}

fn is_allowed_for_directory(file_name: &str, directory: Directory) -> bool {
  match directory {
    Directory::HomeDirectory => {
      is_allowed_in_general(file_name) || (!file_name.starts_with(".")) || file_name.starts_with(".zcompdump")
    }
    _ => is_allowed_in_general(file_name),
  }
}

fn is_allowed_in_general(file_name: &str) -> bool {
  file_name == ".DS_Store" || file_name == ".Trash"
}

fn dir_name(directory: Directory) -> String {
  match directory {
    Directory::ConfigDirectory => "$HOME/.config".to_string(),
    Directory::HomeDirectory => "$HOME".to_string(),
    Directory::TestDirectory => "test_data/test_directory".to_string(),
  }
}

fn dir_path(directory: Directory) -> Result<String, String> {
  match directory {
    Directory::ConfigDirectory => home_relative_path(".config"),
    Directory::HomeDirectory => home_relative_path(""),
    Directory::TestDirectory => Ok("test_data/test_directory".to_string()),
  }
}

fn home_relative_path(under_home: &str) -> Result<String, String> {
  var("HOME").map_err(|err| format!("{}", err)).map(|home| {
    if home.ends_with("/") {
      format!("{}{}", home, under_home)
    } else {
      format!("{}/{}", home, under_home)
    }
  })
}
