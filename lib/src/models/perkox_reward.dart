/// Represents a reward event payload received from the Perkox Offerwall.
class PerkoxReward {
  /// The amount of currency / points rewarded.
  final double amount;

  /// The unique transaction identifier.
  final String txid;

  /// The status of the reward transaction (e.g., "approved", "completed").
  final String status;

  /// The publisher ID associated with the transaction.
  final int? publisherId;

  /// The unique player / user ID who earned the reward.
  final String? playerId;

  /// Unix timestamp when the reward was issued.
  final int? timestamp;

  /// The optional reward type or currency name.
  final String? type;

  /// Raw dictionary representation of the incoming native payload.
  final Map<String, dynamic> raw;

  const PerkoxReward({
    required this.amount,
    required this.txid,
    required this.status,
    this.publisherId,
    this.playerId,
    this.timestamp,
    this.type,
    this.raw = const {},
  });

  /// Constructs a [PerkoxReward] from native platform event data.
  factory PerkoxReward.fromMap(Map<dynamic, dynamic> map) {
    double parseAmount(dynamic val) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    int? parseInt(dynamic val) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val);
      return null;
    }

    return PerkoxReward(
      amount: parseAmount(map['amount']),
      txid: (map['txid'] ?? map['tx_id'] ?? '').toString(),
      status: (map['status'] ?? 'approved').toString(),
      publisherId: parseInt(map['publisher_id'] ?? map['publisherId']),
      playerId: (map['player_id'] ?? map['playerId'])?.toString(),
      timestamp: parseInt(map['timestamp']),
      type: map['type']?.toString(),
      raw: Map<String, dynamic>.from(map),
    );
  }

  /// Converts the reward model to a standard Map.
  Map<String, dynamic> toMap() => {
        'amount': amount,
        'txid': txid,
        'status': status,
        'publisher_id': publisherId,
        'player_id': playerId,
        'timestamp': timestamp,
        'type': type,
      };

  @override
  String toString() {
    return 'PerkoxReward(amount: $amount, txid: $txid, status: $status, playerId: $playerId, timestamp: $timestamp, type: $type)';
  }
}
