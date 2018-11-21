require 'swagger_helper'

describe "Get Objects API" do
  path "/get_objects" do
    # use post since list of objects could be very large and get request has smaller size limit
    # however, must use named value pairs to exceed url length limit, which this example does not
    post "retrieves objects by id" do
      security [ apiKey: [], appId: [] ]
      produces 'application/json'
      # TODO refactor parameter
      # Could not render JsonSchema_array, see the console
      # because query param of type array has no standard
      # update to use post body param 
      parameter name: :objects, description: 'array of object ids',
        in: :query, type: :array, required: true
      parameter name: :pretty, description: 'indent json so it is human readable', 
        in: :query, type: :boolean, default: false, required: false

      include_context 'rswag_user_with_collections', status: 'published'

      response "401", "Must be signed in to access this route" do
        let(:user_token) { nil }
        let(:user_email) { nil }
        let(:objects) { @collections.map(&:id) }

        include_context 'rswag_include_json_spec_output' do
          it_behaves_like 'a json api error'
          it_behaves_like 'a json api 401 error',
            message: "You need to sign in or sign up before continuing."
          it_behaves_like 'a pretty json response'
        end
      end

      response "200", "Objects found" do
        let(:user_token) { @example_user.authentication_token }
        let(:user_email) { CGI.escape(@example_user.to_s) }

        # objects should have licences
        context 'get objects' do
          let(:objects) { @collections.map { |c| c.governed_items.map(&:id) }.flatten }
          exn = "/get_objects?objects=(object ids)"
          include_context 'rswag_include_json_spec_output', example_name=exn do
            run_test! do
              json_response = JSON.parse(response.body)
              json_response.each do |object|
                # get licence (stored at collection level)
                pid = object['pid']
                governing_collection = @collections.select do |c| 
                  c.governed_items.map(&:id).include?(pid)
                end
                licence = Licence.find_by(name: governing_collection.first.licence)
                expect(object['metadata']['licence']).to eq licence.show
              end
            end
          end
        end

        # collections should not have licences
        context 'get collections' do
          let(:objects) { @collections.map(&:id) }
          exn = "/get_objects?objects=(collection ids, \
                  no licence info because metadata is cc-by)"
          include_context 'rswag_include_json_spec_output', example_name=exn do
            it_behaves_like 'a pretty json response'
          end
        end
      end
    end
  end
end