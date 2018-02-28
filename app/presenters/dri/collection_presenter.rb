module DRI
  class CollectionPresenter

    attr_reader :document
    delegate :catalog_path, to: :@view

    def initialize(document, view_context)
      @view = view_context
      @document = document
    end
    
    def display_children
      children.map { |child| display_child(child) }
    end

    private

    Child = Struct.new(:id, :link_text, :path, :type, :cover) do
      def to_partial_path
        'child'
      end
    end

    def display_child(child_doc)
      link_text = child_doc[Solrizer.solr_name('title', :stored_searchable, type: :string)].first
      # FIXME: For now, the EAD type is indexed last in the type solr index, review in the future
      type = child_doc[Solrizer.solr_name('type', :stored_searchable, type: :string)].last
      cover = child_doc[Solrizer.solr_name('cover_image', :stored_searchable, type: :string).to_sym].presence

      child = Child.new
      child.id = child_doc['id']
      child.link_text = link_text
      child.path = catalog_path(child_doc['id'])
      child.cover = cover
      child.type = type

      child
    end
  end
end
