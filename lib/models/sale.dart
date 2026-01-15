class Sale {
  int? id;
  int productId;
  int quantity;
  int price;
  int total;
  String createdAt;

  Sale({
    this.id,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.total,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
      'total': total,
      'created_at': createdAt,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      productId: map['product_id'],
      quantity: map['quantity'],
      price: map['price'],
      total: map['total'],
      createdAt: map['created_at'],
    );
  }
}
