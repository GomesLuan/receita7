import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DataService{
  final ValueNotifier<Map> tableStateNotifier = ValueNotifier({
    "jsonObjects" : [], 
    "propertyNames" : [""],
    "columnNames" : [""],
  });
  String itemCount = '5';

  void carregar(index) {
    var res = null;
    List<Function> loads = [carregarCafes, carregarCervejas, carregarNacoes];
    loads[index]();
  }

  Future<void> carregarCafes() async {
    var coffeesUri = Uri(
      scheme: 'https',
      host: 'random-data-api.com',
      path: 'api/coffee/random_coffee',
      queryParameters: {'size': itemCount}
    );

    var jsonString = await http.read(coffeesUri);
    var coffeesJson = jsonDecode(jsonString);
    tableStateNotifier.value = {
      "jsonObjects" : coffeesJson,
      "propertyNames" : ["blend_name", "origin", "variety"],
      "columnNames" : ["Nome", "Origem", "Variedade"]
    };
  }

  Future<void> carregarCervejas() async {
    var beersUri = Uri(
      scheme: 'https',
      host: 'random-data-api.com',
      path: 'api/beer/random_beer',
      queryParameters: {'size': itemCount}
    );

    var jsonString = await http.read(beersUri);
    var beersJson = jsonDecode(jsonString);
    tableStateNotifier.value = {
      "jsonObjects" : beersJson,
      "propertyNames" : ["name","style","ibu"],
      "columnNames" : ["Nome", "Estilo", "IBU"]
    };
  }

  Future<void> carregarNacoes() async {
    var nationsUri = Uri(
      scheme: 'https',
      host: 'random-data-api.com',
      path: 'api/nation/random_nation',
      queryParameters: {'size': itemCount}
    );

    var jsonString = await http.read(nationsUri);
    var nationsJson = jsonDecode(jsonString);
    tableStateNotifier.value = {
      "jsonObjects" : nationsJson,
      "propertyNames" : ["nationality", "language", "capital"],
      "columnNames" : ["Nacionalidade", "Idioma", "Capital"]
    };
  }
}

final dataService = DataService();

void main() {
  MyApp app = MyApp();
  runApp(app);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      debugShowCheckedModeBanner:false,
      home: Scaffold(
        appBar: AppBar( 
          title: const Text("Dicas"),
        ),
        body: NewBody(),
        bottomNavigationBar: NewNavBar(itemSelectedCallback: dataService.carregar),
      )
    );
  }
}

class NewBody extends HookWidget {
  NewBody();

  @override
  Widget build(BuildContext context) {
    var state = useState('5');
    return SingleChildScrollView(
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: state.value,
            decoration: InputDecoration(labelText: 'Número de itens'),
            padding: EdgeInsets.all(16),
            items: [
              DropdownMenuItem(
                value: '5',
                child: Text('5')
              ),
              DropdownMenuItem(
                value: '10',
                child: Text('10')
              ),
              DropdownMenuItem(
                value: '15',
                child: Text('15')
              )
            ],
            onChanged: (value) {  
              state.value = value.toString();
              dataService.itemCount = state.value;
            }
          ),
          ValueListenableBuilder(
            valueListenable: dataService.tableStateNotifier,
            builder:(_, value, __){
              return DataTableWidget(
                jsonObjects: value["jsonObjects"], 
                propertyNames: value["propertyNames"],
                columnNames: value["columnNames"]
              );
            }
          )
        ]
      )
    );
  }
}

class NewNavBar extends HookWidget {
  final _itemSelectedCallback;

  NewNavBar({itemSelectedCallback}):
    _itemSelectedCallback = itemSelectedCallback ?? (int){}

  @override
  Widget build(BuildContext context) {
    var state = useState(1);
    return BottomNavigationBar(
      onTap: (index){
        state.value = index;
        _itemSelectedCallback(index);                
      }, 
      currentIndex: state.value,
      items: const [
        BottomNavigationBarItem(
          label: "Cafés",
          icon: Icon(Icons.coffee_outlined),
        ),
        BottomNavigationBarItem(
          label: "Cervejas", 
          icon: Icon(Icons.local_drink_outlined)
        ),
        BottomNavigationBarItem(
          label: "Nações", 
          icon: Icon(Icons.flag_outlined)
        )
      ]
    );
  }
}

class DataTableWidget extends StatelessWidget {
  final List jsonObjects;
  final List<String> columnNames;
  final List<String> propertyNames;

  DataTableWidget( {this.jsonObjects = const [], this.columnNames = const ["Nome","Estilo","IBU"], this.propertyNames= const ["name", "style", "ibu"]});

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: columnNames.map( 
        (name) => DataColumn(
          label: Expanded(
            child: Text(name, style: TextStyle(fontStyle: FontStyle.italic))
          )
        )
      ).toList(),
      rows: jsonObjects.map( 
        (obj) => DataRow(
          cells: propertyNames.map(
            (propName) => DataCell(Text(obj[propName]))
          ).toList()
        )
      ).toList()
    );
  }
}