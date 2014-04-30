module Utils

  def numeric?(number)
    Integer(number) rescue false
  end


  def dcterms_point_to_geojson(point)
    point_hash = {}

    point.split(/\s*;\s*/).each do |component|
      (key,value) = component.split(/\s*=\s*/)
      point_hash[key] = value
    end

    return nil if point_hash.count < 3

    tmp_hash = {}
    geojson_hash = {}
    geojson_hash[:type] = 'Feature'
    geojson_hash[:geometry] = {}

    coords = [Float(point_hash['east']), Float(point_hash['north'])]
    tmp_hash[:name] = point_hash['name']

    geojson_hash[:geometry][:type] = 'Point'
    geojson_hash[:geometry][:coordinates] = coords
    geojson_hash[:properties] = tmp_hash

    return geojson_hash
  end


  def dcterms_box_to_geojson(box)
    point_hash = {}

    box.split(/\s*;\s*/).each do |component|
      (key,value) = component.split(/\s*=\s*/)
      point_hash[key] = value
    end

    return nil if point_hash.count < 3

    tmp_hash = {}
    geojson_hash = {}
    geojson_hash[:type] = 'Feature'
    geojson_hash[:geometry] = {}

    coords = [[
      [Float(point_hash['westlimit']), Float(point_hash['northlimit'])],
      [Float(point_hash['westlimit']), Float(point_hash['southlimit'])],
      [Float(point_hash['eastlimit']), Float(point_hash['southlimit'])],
      [Float(point_hash['eastlimit']), Float(point_hash['northlimit'])]
    ]]
    tmp_hash[:name] = point_hash['name']

    geojson_hash[:geometry][:type] = 'Polygon'
    geojson_hash[:geometry][:coordinates] = coords
    geojson_hash[:properties] = tmp_hash

    return geojson_hash
  end
end
