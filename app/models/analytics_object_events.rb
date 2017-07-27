class AnalyticsCollectionEvents
    extend Legato::Model

    filter :collections, &lambda {|*collections| collections.map {|collectionid| matches(:eventCategory, collectionid)}}
    filter :action, &lambda {|action| matches(:eventAction, action)}

    metrics :totalEvents, :uniqueEvents
    dimensions :eventAction, :eventCategory, :eventLabel
end
