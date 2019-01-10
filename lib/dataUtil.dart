import 'package:lineage2_servers_status/models/server.dart';

const String URL_L2_LABY_FR = 'http://l2.laby.fr/status/cache.txt';

Server refreshDataServer(String dataRaw, String nameRaw) {
  if (dataRaw.isEmpty) return null;

  return refreshDataServers(dataRaw, filter: nameRaw).first;
}

List<Server> refreshDataServers(String dataRaw, {String filter}) {
  if (dataRaw.isEmpty) return _serversDefault;

  var serversList = _dataSanitization(dataRaw);

  if (filter != null && filter.isNotEmpty)
    serversList = new List<String>()..add(serversList.firstWhere((s) => s.contains(filter)));

  var serversUpdated = serversList.map((row) => _buildServerData(row)).toList();

  List<Server> servers = new List<Server>();
  for (var s in _serversDefault) {
    if(filter == null) {
      servers.add(_refreshServer(s, serversUpdated));
    } else if(filter == s.nameRaw){
      servers.add(_refreshServer(s, serversUpdated));
      break;
    }
  }
  return servers;
}

List<String> _dataSanitization(String dataRaw) {
  var dataRawFiltered = dataRaw
      .replaceAll('<table class="status_table">', '')
      .replaceAll('</table>', '')
      .replaceAll('<tr><td class="server_name" nowrap>- ', '')
      .replaceAll(' players', '')
      .replaceAll('server_up', '')
      .replaceAll('server_down', '')
      .replaceAll('</span></td></tr>', ';')
      .replaceAll('</td><td>&emsp;</td>  <td><span class="', '')
      .replaceAll('">', '|')
      .trim();

  var serversList =
      dataRawFiltered.substring(0, dataRawFiltered.length - 1).split(';');
  return serversList;
}

Server _refreshServer(Server server, List<MapEntry> serversUpdated) {
  for (var su in serversUpdated) {
    if (su.key.contains(server.nameRaw)) {
      return new Server(
          server.name, server.nameRaw, server.type, server.country, su.value);
    }
  }
  return server;
}

MapEntry _buildServerData(String row) {
  List<String> dataRow = row.split('|');

  String name = dataRow.first;
  int players = int.tryParse(dataRow.last);

  if (players == null) players = 0;

  return new MapEntry(name, players);
}

final List<Server> _serversDefault = [
  Server("Chronos", "Chronos", "GOD", "NA"),
  Server("Naia", "Naia", "GOD", "NA"),
  Server("Talking Island", "Talking Island (NA Classic)", "Classic", "NA"),
  Server("Giran", "Giran (NA Classic)", "Classic", "NA"),
  Server("Aden", "Aden (NA Classic)", "Classic", "NA"),
  Server("Gludio", "Gludio (NA Classic)", "Classic", "NA"),
  Server("Aden F2P", "Aden (KR Classic F2P)", "Classic", "KR"),
  Server("New Aden F2P", "New Aden (KR Classic F2P)", "Classic", "KR"),
  Server("Talking Island", "Talking Island (KR Classic)", "Classic", "KR"),
  Server("New Gludio", "New Gludio (KR Classic)", "Classic", "KR"),
  Server("지그하르트 New Sieghardt", "(New Sieghardt)", "", "KR"),
  Server("바츠 New Bartz", "(New Bartz)", "", "KR"),
  Server("카인 New Kain", "(New Kain)", "", "KR"),
  Server("블러디 Bloody", "(Bloody KR)", "", "KR"),
  Server("PTS", "PTS KR", "", "KR"),
];
