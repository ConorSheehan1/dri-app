require 'swagger_helper'

describe "Catalog API" do
  path "/catalog" do
    get "retrieves objects from the catalog" do
      # tags 'catalog'
      produces "application/json"
      include_context 'rswag_user_with_collections', status: 'published'

      parameter name: :per_page, description: 'Number of results per page', 
        in: :query, type: :number, default: 9
      parameter name: :mode, description: 'Show Objects or Collections', 
        in: :query, type: :string, default: 'objects'
      parameter name: :pretty, in: :query, type: :boolean, required: false,
        description: 'indent json so it is human readable'

      let(:per_page) { 9 }
      let(:mode)     { 'objects' }

      response '200', 'catalog found' do
        include_context 'sign_out_before_request'
        include_context 'rswag_include_json_spec_output'
        it_behaves_like 'a pretty json response'
      end
    end
  end
end
