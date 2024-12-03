enum BookingStatus {
  PENDING,
  ACCEPTED,
  STARTED,
  DENIED,
  COMPLETED,
  CANCELED;

  @override
  String toString() {
    switch (this) {
      case BookingStatus.PENDING:
        return 'PENDING';
      case BookingStatus.ACCEPTED:
        return 'ACCEPTED';
      case BookingStatus.STARTED:
        return 'STARTED';
      case BookingStatus.DENIED:
        return 'DENIED';
      case BookingStatus.COMPLETED:
        return 'COMPLETED';
      case BookingStatus.CANCELED:
        return 'CANCELED';
      default:
        return '';
    }
  }
}
