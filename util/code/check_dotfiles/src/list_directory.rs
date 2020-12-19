use std::fs::{read_dir, DirEntry, ReadDir};
use std::path::Path;

pub fn list_directory(path: &str) -> Result<Vec<String>, String> {
  read_dir(Path::new(path))
    .map_err(|err| format!("{}: {}", path, err))
    .and_then(|rd| to_file_names(rd, path))
}

fn to_file_names(read_dir: ReadDir, path: &str) -> Result<Vec<String>, String> {
  let mut file_names: Vec<String> = Vec::new();
  for entry_result in read_dir {
    match entry_result {
      Ok(entry) => file_names.push(to_file_name(entry)),
      Err(err) => return Err(format!("{}: {}", path, err)),
    }
  }
  file_names.sort();
  Ok(file_names)
}

fn to_file_name(entry: DirEntry) -> String {
  String::from(entry.file_name().to_string_lossy())
}
