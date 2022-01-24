import 'dart:convert';

class WalletBalance {
  final String wallet;
  WalletBalance({
    required this.wallet,
  });

  WalletBalance copyWith({
    String? wallet,
  }) {
    return WalletBalance(
      wallet: wallet ?? this.wallet,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'wallet': wallet,
    };
  }

  factory WalletBalance.fromMap(Map<String, dynamic> map) {
    return WalletBalance(
      wallet: map['wallet'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory WalletBalance.fromJson(String source) =>
      WalletBalance.fromMap(json.decode(source));

  @override
  String toString() => 'WalletBalance(wallet: $wallet)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WalletBalance && other.wallet == wallet;
  }

  @override
  int get hashCode => wallet.hashCode;
}
