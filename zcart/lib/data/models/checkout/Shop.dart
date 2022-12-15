class Shop {
  Shop({
      this.id, 
      this.name, 
      this.slug, 
      this.verified, 
      this.verifiedText, 
      this.image, 
      this.contactNumber, 
      this.rating, 
      this.feedbacksCount,});

  Shop.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
    verified = json['verified'];
    verifiedText = json['verified_text'];
    image = json['image'];
    contactNumber = json['contact_number'];
    rating = json['rating'];
    feedbacksCount = json['feedbacks_count'];
  }
  int? id;
  String? name;
  String? slug;
  bool? verified;
  String? verifiedText;
  String? image;
  dynamic contactNumber;
  dynamic rating;
  int? feedbacksCount;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['slug'] = slug;
    map['verified'] = verified;
    map['verified_text'] = verifiedText;
    map['image'] = image;
    map['contact_number'] = contactNumber;
    map['rating'] = rating;
    map['feedbacks_count'] = feedbacksCount;
    return map;
  }

}