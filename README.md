# README

# Simple Drive

A simple file storage application using Ruby on Rails, Docker, and various storage strategies.

## Getting Started

To get the project up and running, you only need Docker installed on your machine.

### Prerequisites

- Docker

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/MrQassem/drive-storage.git
   ```

2. Navigate to the project directory:

   ```bash
   cd drive-storage
   ```

3. Before running the application, you need to set up the environment variables required for the storage strategies and other configurations. Follow these steps:

   - Rename the .env.example file to .env:
   - Open the .env file in a text editor and fill in the values for the environment variables:
     - <b>BUCKET_NAME</b>: The name of your AWS S3 bucket.
     - <b>REGION_NAME</b>: The AWS region where your S3 bucket is located.
     - <b>ACCESS_KEY</b>: Your AWS access key ID.
     - <b>SECRET_KEY</b>: Your AWS secret access key.

4. Build and start the Docker containers:

   ```bash
   docker-compose up --build
   ```

The application should now be running and accessible at http://localhost:3000.

### Running Tests

- To run the tests, you can execute the following command inside the drive-app container:

  ```bash
  docker exec -it drive-app bash
  rspec
  ```

### Connecting to the Database

- You can connect to the PostgreSQL database using the following credentials:

  - <b>Host</b>: 127.0.0.1
  - <b>User</b>: postgres
  - <b>Password</b>: example
  - <b>Database</b>: postgres

### Accessing the FTP Server

- To access files stored on the FTP server, you can use the following command to enter the drive-ftp container:

  ```bash
  docker exec -it drive-ftp bash
  cd home/storage
  ```

### Generating a Token

- To generate a bearer token, use the /generate_token endpoint by providing a user_id in the body:

  ```bash
  curl -X POST http://localhost:3000/generate_token -d '{"user_id": "1"}' -H "Content-Type: application/json"
  ```

### API Endpoints

- <b>GET </b>/health/live: Health check endpoint.
- <b>POST</b> /generate_token: Generate a bearer token for authentication.
- <b>POST</b> /v1/blobs: Create a new blob in the storage.
- <b>GET </b>/v1/blobs/:id: Retrieve a blob from the storage.

## Storage Strategies

- This project uses the strategy pattern to support different storage strategies:

  - Local Storage: Files are stored locally on the server.
  - S3 Storage: Files are stored in an AWS S3 bucket.
  - FTP Storage: Files are stored on an FTP server.
  - The strategy pattern allows for easy extension and integration of additional storage strategies without modifying the core application logic.

## Built With

-
- <b>Ruby on Rails</b> - The web framework used
- <b>Docker</b> - Containerization platform
- <b>RSpec</b> - Testing framework

## Assumptions

- Here are some assumptions that may have been made in the project:

  - <b>Authentication:</b> It is assumed that the user authentication is handled outside of the storage functionality. The user_id used in the generate_token endpoint and for storing blobs is not validated or linked to an actual user database.

  - <b>Storage Strategy:</b> The project assumes that the storage strategy (Local, S3, or FTP) is pre-configured and does not dynamically switch between strategies based on runtime conditions.

  - <b>Error Handling:</b> The project assumes that basic error handling is sufficient for the scope of the application. More complex error handling and logging mechanisms may be required for production environments.

  - <b>Data Validation:</b> The project assumes that the data provided to the storage strategies, particularly the data field for blobs, is valid and does not require extensive validation.

  - <b>Environment Configuration:</b> It is assumed that the environment variables for configuring the storage strategies (e.g., ACCESS_KEY, SECRET_KEY, BUCKET_NAME for S3) are properly set up.
