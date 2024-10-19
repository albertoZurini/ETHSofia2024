use anyhow::Result;
use blocksense_sdk::{
    oracle::{DataFeedResult, DataFeedResultValue, Payload, Settings},
    oracle_component,
    spin::http::{send, Method, Request, Response},
};
use serde::Deserialize;
use url::Url;

fn simple_hash(value: &str, salt: &str) -> u64 {
    let combined = format!("{}{}", value, salt);
    let mut hash: u64 = 0;
    
    for byte in combined.bytes() {
        hash = hash.wrapping_add(byte as u64);
        hash = hash.wrapping_mul(31);
    }
    
    hash
}

#[derive(Deserialize, Debug)]
#[allow(dead_code)]
struct Rate {
    from: String,
    to: String,
    rate: f64,
    timestamp: u64,
}

#[oracle_component]
async fn oracle_request(settings: Settings) -> Result<Payload> {
    let mut payload: Payload = Payload::new();

    for data_feed in settings.data_feeds.iter() {

        if data_feed.id == "123" {
            let result = handle_message(data_feed.data.as_str());
            payload.values.push(DataFeedResult {
                id: "123".to_string(),
                value: DataFeedResultValue::Text(result),
            });
            println!("{:?}", &payload.values);
        } else {

            let url = Url::parse(format!("https://www.revolut.com/api/quote/public/{}", data_feed.data).as_str())?;
            println!("URL - {}", url.as_str());
            let mut req = Request::builder();
            req.method(Method::Get);
            req.uri(url);
            req.header("user-agent", "*/*");
            req.header("Accepts", "application/json");

            let req = req.build();
            let resp: Response = send(req).await?;

            let body = resp.into_body();
            let string = String::from_utf8(body).expect("Our bytes should be valid utf8");
            let value: Rate = serde_json::from_str(&string).unwrap();

            println!("{:?}", value);

            payload.values.push(DataFeedResult {
                id: data_feed.id.clone(),
                value: DataFeedResultValue::Numerical(value.rate),
            });
        }
    }
    Ok(payload)
}

fn handle_message(message: &str) -> String {
    // Your logic here
    let hashed = simple_hash(message, "Secret");
    println!("Message received: {} --- hashed: {}", message, hashed);
    hashed.to_string()
}