class SlotDetails {
  final String id;
  final String timeSlot;
  final String bookingDate;
  final String name;
  final String email;
  final String mobile;
  final String status;
  final String submitDate;
  final String companyName;

  SlotDetails({
    required this.id,
    required this.timeSlot,
    required this.bookingDate,
    required this.name,
    required this.email,
    required this.mobile,
    required this.status,
    required this.submitDate,
    required this.companyName,
  });

  factory SlotDetails.fromJson(Map<String, dynamic> json) {
    return SlotDetails(
      id: json['id'].toString(),
      timeSlot: json['time_slot'],
      bookingDate: json['booking_date'],
      name: json['name'],
      email: json['email'],
      mobile: json['mobile'],
      status: json['status'],
      submitDate: json['submit_date'],
      companyName: json['company_name'],
    );
  }

  // Add this method to convert from another SlotDetails object
  factory SlotDetails.from(dynamic other) {
    // Handle case when other is a map
    if (other is Map<String, dynamic>) {
      return SlotDetails.fromJson(other);
    }
    // Handle case when other is another SlotDetails-like object
    return SlotDetails(
      id: other.id ?? '',
      timeSlot: other.timeSlot ?? '',
      bookingDate: other.bookingDate ?? '',
      name: other.name ?? '',
      email: other.email ?? '',
      mobile: other.mobile ?? '',
      status: other.status ?? '',
      submitDate: other.submitDate ?? '',
      companyName: other.companyName ?? '',
    );
  }
}
