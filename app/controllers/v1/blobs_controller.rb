require 'base64'

module V1
  class BlobsController < ApplicationController
    include S3Service

    skip_before_action :verify_authenticity_token

    def create
      """
      Creates a new blob in the S3 bucket
      
      Params:
        id (String): The unique identifier for the blob.
        data (String): The Base64 encoded data of the blob.
      
      Returns:
        JSON response with the created blob's ID and data.
      """
      body_params = JSON.parse(request.body.read)

      id = body_params['id']
      data = body_params['data']
    

      # Check if both 'id' and 'data' are present
      if id.blank? || data.blank?
        return render json: { error: 'Both `id` and `data` are required' }, status: :bad_request
      end

      # Verify that data can be decoded
      begin
        Base64.decode64(data)
      rescue ArgumentError
        return render json: { error: 'Invalid Base64 data' }, status: :bad_request
      end

      # Write data to S3
      
      response = write_to_s3(id, data)
      if response.code.to_i == 200
        render json: { id: id, data: data }, status: :created
      else
        render json: { error: 'Blob could not be stored' }, status: 400
      end
      
    end

    def show
      """
      Retrieves a blob from the S3 bucket.
      
      Params:
        id (String): The unique identifier for the blob.
      
      Returns:
        JSON response with the blob's ID, Base64 encoded data, size, and creation timestamp.
      """

      id = params[:id]
      
      response = read_from_s3(id)
      if response.code.to_i==200
        base64_data = response.body
        render json: {
          id: id,
          data: base64_data,
          # TODO, these are to be stored in the db upon storing to storage.
          size: Base64.strict_decode64(base64_data).bytesize,
          created_at: Time.now.utc.iso8601
        }
      else
        render json: { error: 'Blob not found' }, status: :not_found
      end
    end
  end
end
