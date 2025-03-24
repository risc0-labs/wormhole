#[derive(thiserror::Error, Debug)]
pub enum Error {
    #[error("Some argument was invalid")]
    InvalidArgument,
    #[error("IO error")]
    Io(#[from] std::io::Error),
    #[error("Signature error")]
    Signature(#[from] alloy::primitives::SignatureError),
    #[error("Not enough signatures on VAA to meet quorum")]
    QuorumNotMet,
}

pub type Result<T> = std::result::Result<T, Error>;
