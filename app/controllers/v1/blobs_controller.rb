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
      # TODO: this user_id should be extracted from the bearer token provided, but for now user_id is 1
      user_id=1

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
      
      begin
        # Write data to S3
        storage_path="#{user_id}/#{id}"
        response = write_to_s3(storage_path, body_params['data'])
        
        if response.code.to_i == 200
          # Store metadata in the Blob model
          Blob.create!(
            blob_id: id, 
            # TODO: this user_id should be extracted from the bearer token provided, but for now user_id is 1
            user_id: user_id, 
            storage_type: 's3',
            storage_path: storage_path,
            content_type: 'application/base64',
            size: Base64.strict_decode64(body_params['data']).bytesize
          )
          render json: { id: id, data: data }, status: :created
        else
          render json: { error: 'Blob could not be stored' }, status: response.code.to_i
        end
      rescue ActiveRecord::RecordNotUnique => e
        render json: { error: 'A blob with the given ID and user ID already exists.' }, status: :unprocessable_entity
      rescue => e
        puts e
        render json: { error: 'Blob could not created due to some errors' }, status: :bad_request
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

      # TODO: this user_id should be extracted from the bearer token provided, but for now user_id is 1
      user_id= 1
      blob = Blob.find_by(blob_id: id, user_id: user_id)
      puts blob.storage_path
      if blob
        # Blob found in the database, now retrieve it from S3
        response = read_from_s3(blob.storage_path)
        if response.code.to_i == 200
          base64_data = Base64.strict_encode64(response.body)
          render json: {
            id: blob.blob_id,
            data: base64_data,
            size: blob.size,
            created_at: blob.created_at.iso8601
          }
        else
          render json: { error: 'Blob not found in S3' }, status: :not_found
        end
      else
        render json: { error: 'Blob not found in database' }, status: :not_found
      end
    end
  end
end
