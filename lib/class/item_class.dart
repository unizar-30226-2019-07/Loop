class ItemClass {
  final int id;
  final String name;
  final String tagline;
  final String description;
  final String imageUrl; // TODO almacenar imagen y no URL
  final String price;

  ItemClass.fromJSON(Map<String, dynamic> jsonMap) :
    id = jsonMap['id'],
    name = jsonMap['name'],
    tagline = jsonMap['tagline'],
    description = jsonMap['description'],
    imageUrl = jsonMap['image_url'],
    price = jsonMap['abv'].toString() + '€';
}
