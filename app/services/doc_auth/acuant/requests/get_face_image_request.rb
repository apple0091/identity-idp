module DocAuth
  module Acuant
    module Requests
      class GetFaceImageRequest < DocAuth::Acuant::Request
        attr_reader :instance_id

        def initialize(config:, instance_id:)
          super(config: config)
          @instance_id = instance_id
        end

        def path
          "/AssureIDService/Document/#{instance_id}/Field/Image?key=Photo"
        end

        def handle_http_response(http_response)
          DocAuth::Acuant::Responses::GetFaceImageResponse.new(http_response)
        end

        def method
          :get
        end

        def metric_name
          'acuant_doc_auth_get_face_image'
        end
      end
    end
  end
end
