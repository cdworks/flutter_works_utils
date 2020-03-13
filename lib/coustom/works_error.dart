

class WorksError extends Error
{
  static const String WorksNetDomain = "netDomain";

  static const String LocalizedDescriptionKey = "descriptionKey";

  WorksError(this.code,{this.domain = WorksNetDomain, this.userInfo}) : super();

    final int code;

    ///The error domain—this can be one of the predefined NSError domains, or an arbitrary string describing a custom domain.
    /// domain must not be nil. See Error Domains for a list of predefined domains.
    final String domain;

    final Map<String,dynamic> userInfo;

    String get localizedDescription  => userInfo[LocalizedDescriptionKey] ?? "";

}
