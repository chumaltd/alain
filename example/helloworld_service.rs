use tonic::{Request, Response, Status};

pub mod helloworld {
  tonic::include_proto!("helloworld");
}

use helloworld::{
  HelloRequest,
  HelloReply,
};

pub struct GreeterService {}

#[tonic::async_trait]
impl Greeter for GreeterService {

  async fn say_hello(&self, request: Request<HelloRequest>) -> Result<Response<HelloReply>, Status> {
    let message = request.into_inner();
    Ok(Response::new(HelloReply { }))
  }

}
