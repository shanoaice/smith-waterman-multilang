use std::fs;
use clap::Parser;

use crate::algorithm::smith_waterman;

pub mod algorithm;

#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
struct Args {
    /// subject sequence file, raw DNA sequence
    #[arg(short, long)]
    subject: String,

    /// query sequence file, raw DNA sequence
    #[arg(short, long)]
    query: String,

    #[arg(short, long, default_value = "2")]
    match_bonus: i32,

    #[arg(short = 'M', long, default_value = "1")]
    mismatch_penalty: i32,

    #[arg(short, long, default_value = "2")]
    gap_penalty: i32,
}

fn main() {
    let args = Args::parse();

    match fs::exists(&args.subject) {
        Ok(exists) => {
            if !exists  {
                println!("Subject file {} does not exist!", &args.subject);
                std::process::exit(1);
            }
        },
        Err(e) => {
            println!("Cannot read subject file {}", &args.subject);
            println!("{:?}", e);
            std::process::exit(1);
        }
    }

    match fs::exists(&args.query) {
        Ok(exists) => {
            if !exists  {
                println!("Subject file {} does not exist!", &args.query);
                std::process::exit(1);
            }
        },
        Err(e) => {
            println!("Cannot read subject file {}", &args.query);
            println!("{:?}", e);
            std::process::exit(1);
        }
    }

    // it shouldn't error because exists checked.
    let subject = fs::read_to_string(&args.subject).unwrap().trim().to_string();
    let query = fs::read_to_string(&args.query).unwrap().trim().to_string();

    let score_info = algorithm::ScoreInfo {
        match_bonus: args.match_bonus,
        mismatch_penalty: args.mismatch_penalty,
        gap_penalty: args.gap_penalty,
    };

    let (subject_line, query_line) = smith_waterman(&subject, &query, &score_info);

    println!("{}", subject_line);
    println!("{}", query_line);
}
