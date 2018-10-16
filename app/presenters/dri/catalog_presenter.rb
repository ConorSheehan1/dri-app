module DRI
  class CatalogPresenter < ObjectPresenter

    delegate :object_file_url, to: :@view

    def children
      @children ||= document.children(100).select { |child| child.published? }
    end

    def displayfiles
      @displayfiles ||= document.assets(ordered: true)
    end

    def surrogate_exists?(id, name)
      document.surrogates(id).key?(name)
    end

    def relationships
      @relationships ||= object_relationships
    end

    private

      def object_relationships
        relationships = document.object_relationships
        filtered_relationships = {}

        relationships.each do |key, array|
          filtered_array = array.select { |item| item[1].published? }
          unless filtered_array.empty?
            filtered_relationships[key] = Kaminari.paginate_array(filtered_array).page(params[key.downcase.gsub(/\s/, '_') << '_page']).per(4)
          end
        end

        filtered_relationships
      end
  end
end
