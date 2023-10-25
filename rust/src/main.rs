use std::io::prelude::*;
use std::net::TcpStream;

fn main() -> std::io::Result<()> {
    if let Ok(mut stream) = TcpStream::connect("localhost:9000") {
        println!("Connected!");
        let bytes_written = stream.write(b"world from rust!\n")?;
        println!("bytes written: {}", bytes_written);
        let mut buffer = [0; 128];
        let bytes_read = stream.read(&mut buffer[..])?;
        println!("bytes read: {}", bytes_read);
        println!("Received: {:?}", String::from_utf8_lossy(&buffer));
    } else {
        panic!("Not conntected...");
    }

    Ok(())
}
