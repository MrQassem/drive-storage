module  S3Service
    def initialize
        # Set up the following environment variables in your .env file for S3 connectivity:
        # S3_BUCKET_NAME
        # S3_REGION_NAME
        # AWS_ACCESS_KEY_ID
        # AWS_SECRET_ACCESS_KEY
        @bucket_name = ""
        @region_name = ""
        @access_key = ""
        @secret_key = ""
    
    end
    
  
    def read_from_s3(object_key)
        """
        Reads a file from an S3 bucket.
    
        Args:
        object_key (str): The key (path) of the object to read from S3.
    
        Returns:
        str: The content of the file if successful, or an error message if not.
        """
        # Construct the URL for the S3 object
        host = "#{@bucket_name}.s3.#{@region_name}.amazonaws.com"
        uri = URI.parse("https://#{host}/#{object_key}")

        # Set up the HTTP GET request
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Get.new(uri.request_uri)
        request['Host'] = host
        request['x-amz-date'] = Time.now.utc.strftime('%Y%m%dT%H%M%SZ')
        request['x-amz-content-sha256'] = 'UNSIGNED-PAYLOAD'
        request['Authorization'] = authorization_header(@access_key, @secret_key, request, uri, @region_name)

        # Send the request and handle the response
        response = http.request(request)
    
        if response.code.to_i == 200
            response.body
        else
            "Failed to read file. Response code: #{response.code}, Response body: #{response.body}"
        end
    end
    
    def write_to_s3(object_key, file_path)
        """
        Writes a file to an S3 bucket.
    
        Args:
        object_key (str): The key (path) where the file will be stored in S3.
        file_path (str): The path to the file on the local filesystem.
    
        Returns:
        str: A success message if successful, or an error message if not.
        """
        # Construct the URL for the S3 object
        host = "#{@bucket_name}.s3.#{@region_name}.amazonaws.com"
        uri = URI.parse("https://#{host}/#{object_key}")

        # Set up the HTTP PUT request
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Put.new(uri.request_uri)
        file_content = File.read(file_path)
        request.body = file_content
        # TODO: Adjust the Content-Type to be the type of uploaded file from the endpoint
        request['Content-Type'] = 'image/jpeg'  
        request['Content-Length'] = file_content.bytesize.to_s
        request['Host'] = host
        request['x-amz-date'] = Time.now.utc.strftime('%Y%m%dT%H%M%SZ')
        request['x-amz-content-sha256'] = Digest::SHA256.hexdigest(file_content)
        request['Authorization'] = authorization_header(@access_key, @secret_key, request, uri, @region_name)

        # Send the request and handle the response
        response = http.request(request)
        # TODO: return the response and let client handles it wether success or fail
        if response.code.to_i == 200
        "File uploaded successfully."
        else
        "Failed to upload file. Response code: #{response.code}, Response body: #{response.body}"
        end
    end
  
    def authorization_header(access_key, secret_key, request, uri, region_name)
        """
        Generates the Authorization header for an AWS S3 request.
    
        Args:
        access_key (str): The AWS access key ID.
        secret_key (str): The AWS secret access key.
        request (Net::HTTP): The HTTP request object.
        uri (URI): The URI object for the S3 resource.
        region_name (str): The AWS region name.
    
        Returns:
        str: The Authorization header value.
        """
    
        # Define the algorithm and service name for AWS Signature Version 4.
        algorithm = 'AWS4-HMAC-SHA256'
        service = 's3'
    
        # Extract the date from the x-amz-date header and construct the credential scope.
        amz_date = request['x-amz-date']
        credential_scope = "#{amz_date[0, 8]}/#{region_name}/#{service}/aws4_request"
    
        # Define the headers that are included in the signature.
        signed_headers = 'content-type;host;x-amz-content-sha256;x-amz-date'
    
        # Construct the canonical request, which includes the HTTP method, URI, headers, and payload hash.
        canonical_request = "#{request.method}\n#{uri.path}\n\ncontent-type:#{request['Content-Type']}\nhost:#{request['Host']}\nx-amz-content-sha256:#{request['x-amz-content-sha256']}\nx-amz-date:#{amz_date}\n\n#{signed_headers}\n#{request['x-amz-content-sha256']}"
    
        # Construct the string to sign, which includes the algorithm, credential scope, and hash of the canonical request.
        string_to_sign = "#{algorithm}\n#{amz_date}\n#{credential_scope}\n#{Digest::SHA256.hexdigest(canonical_request)}"
    
        # Generate the signing key using the secret access key, date, region, and service name.
        signing_key = get_signature_key(secret_key, amz_date[0, 8], region_name, service)
    
        # Calculate the signature by hashing the string to sign with the signing key.
        signature = OpenSSL::HMAC.hexdigest('sha256', signing_key, string_to_sign)
        
        # Construct the Authorization header value.
        "#{algorithm} Credential=#{access_key}/#{credential_scope}, SignedHeaders=#{signed_headers}, Signature=#{signature}"
    end
    
    def get_signature_key(key, date_stamp, region_name, service_name)
        """
        Generates the signing key for AWS Signature Version 4.
    
        Args:
        key (str): The AWS secret access key.
        date_stamp (str): The date in YYYYMMDD format.
        region_name (str): The AWS region name.
        service_name (str): The AWS service name.
    
        Returns:
        The signing key.
        """
    
        # Perform a series of HMAC-SHA256 hashing operations to derive the signing key.
        k_date = OpenSSL::HMAC.digest('sha256', "AWS4#{key}", date_stamp)
        k_region = OpenSSL::HMAC.digest('sha256', k_date, region_name)
        k_service = OpenSSL::HMAC.digest('sha256', k_region, service_name)
        k_signing = OpenSSL::HMAC.digest('sha256', k_service, 'aws4_request')
        k_signing
    end
    
end
  