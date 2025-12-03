use std::fs::File;
use std::io::Write;
use anyhow::Result;
use jwt_simple::prelude::*;
use std::path::Path;

fn main() -> Result<()> {
    let private_file_path = "fixtures/private_key.pem";
    let public_file_path = "fixtures/public_key.pem";
    if !Path::new(private_file_path).exists()
        || !Path::new(public_file_path).exists()
    {
        let key_pair = Ed25519KeyPair::generate();
        let private_key_pem = key_pair.to_pem();
        let mut private_key_file = File::create(private_file_path)?;
        private_key_file.write_all(private_key_pem.as_ref())?;

        let public_key_pem = key_pair.public_key().to_pem();
        let mut public_key_file = File::create(public_file_path)?;
        public_key_file.write_all(public_key_pem.as_bytes())?;
    }
    Ok(())
}
