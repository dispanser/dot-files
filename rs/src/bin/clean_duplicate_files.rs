//! Scan a directory, compute an md5 checksum for each file, and delete all but
//! the first occurrence of each checksum.
//!
//! This is going to be used to clean up duplicates in my mail dir, which seems to
//! come from syncing with imap, but also potentially syncing between systems on init.
//! 
//! Cargo manifest. Fenced with`cargo` "language".
//!
//! ```cargo
//! [dependencies]
//! walkdir = "2.5"
//! md5 = "0.7"
//! ```
//!
//!
//!
// cargo-deps: walkdir = "2.5" md5 = "0.7"
extern crate md5;
extern crate walkdir;
use std::collections::HashSet;
use std::fs::{self, File};
use std::io::{self, Read};
use walkdir::WalkDir;

fn main() -> io::Result<()> {
    println!("tyx/main");
    let dir = std::env::args().nth(1).expect("Please provide a directory path");
    let mut checksums: HashSet<String> = HashSet::new();

    // Iterate over all files in the directory
    for entry in WalkDir::new(&dir) {
        let entry = entry?;
        if entry.file_type().is_file() {
            let path = entry.path().to_string_lossy().to_string();
            let checksum = calculate_md5(&path)?;
            if !checksums.insert(checksum.clone()) {
                fs::remove_file(&path)?;
                println!("Deleted duplicate: {}", path);
            }
        }
    }

    Ok(())
}

fn calculate_md5(file_path: &str) -> io::Result<String> {
    let mut file = File::open(file_path)?;
    let mut contents = Vec::new();
    file.read_to_end(&mut contents)?;
    let digest = md5::compute(contents);
    Ok(format!("{:x}", digest))
}
