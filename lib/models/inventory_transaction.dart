class InventoryTransaction {
  int? id;
  int productId;
  int quantity;
  String type; // IN or OUT
  String createdAt;

  InventoryTransaction({
    this.id,
    required this.productId,
    required this.quantity,
    required this.type,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'quantity': quantity,
      'type': type,
      'created_at': createdAt,
    };
  }

  factory InventoryTransaction.fromMap(Map<String, dynamic> map) {
    return InventoryTransaction(
      id: map['id'],
      productId: map['product_id'],
      quantity: map['quantity'],
      type: map['type'],
      createdAt: map['created_at'],
    );
  }
}
