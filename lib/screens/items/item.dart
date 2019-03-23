class Item {
  final int id;
  final String name;
  final String tagline;
  final String description;
  final String image_url;

  Item.fromJSON(Map<String, dynamic> jsonMap) :
    id = jsonMap['id'],
    name = jsonMap['name'],
    tagline = jsonMap['tagline'],
    description = jsonMap['description'],
    image_url = jsonMap['image_url']; 
}
