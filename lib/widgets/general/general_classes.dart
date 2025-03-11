

///DropDownObjects
class DDO {
  final Function stateManager;
  final List list;
  final Map<dynamic, dynamic>? logoList;
  final String searchHint;

  DDO(this.logoList,
      {required this.searchHint,
      required this.stateManager,
      required this.list});
}



