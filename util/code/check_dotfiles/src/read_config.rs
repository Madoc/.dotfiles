use std::fs::read_to_string;
use std::path::Path;

#[test]
fn test() {
  assert_eq!(
    read_config("test_data/config.txt").unwrap(),
    vec![".bar", ".config/baz", ".foo"]
  )
}

pub fn read_config(filename: &str) -> Result<Vec<String>, String> {
  read_to_string(Path::new(filename))
    .map_err(|err| format!("{}: {}", filename, err))
    .and_then(|whole_file| parse_config(whole_file, filename))
}

fn parse_config(whole_file: String, filename: &str) -> Result<Vec<String>, String> {
  let mut result: Vec<String> = Vec::new();
  for entry_result in whole_file.split("\n").map(|line| parse_line(line, filename)) {
    match entry_result {
      Ok(None) => (),
      Ok(Some(entry)) => result.push(entry),
      Err(err) => return Err(err),
    };
  }
  result.sort();
  result.dedup();
  Ok(result)
}

fn parse_line(line: &str, filename: &str) -> Result<Option<String>, String> {
  let trimmed = match line.find('#') {
    Some(index) => &line[..index],
    None => line,
  }
  .trim();
  if trimmed.is_empty() {
    Ok(None)
  } else if trimmed.starts_with(".") || trimmed.starts_with(".config/") {
    Ok(Some(String::from(trimmed)))
  } else {
    Err(format!(
      "{}: Entries must start with '.' or '.config/': {}",
      filename, line
    ))
  }
}
