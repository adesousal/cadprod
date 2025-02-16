import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class Cadastro extends StatefulWidget {
  final Map? produto; // Para edição, se for passado  
  const Cadastro({Key? key, this.produto}) : super(key: key);

  @override
  _CadastroState createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _corController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  List<String> imagensBase64 = [];
  bool editando = false;
  int index = 0;
  String? codigoOriginal;

  @override
  void initState() {
    super.initState();
    if (widget.produto != null) {
      codigoOriginal = widget.produto!['codigo'];
      _codigoController.text = widget.produto!['codigo'];
      _corController.text = widget.produto!['cor'];
      _descricaoController.text = widget.produto!['descricao'];
      imagensBase64 = List<String>.from(widget.produto!['imagens']);
      editando = true;
    }
  }

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/produtos.json');
  }

  Future<List<dynamic>> readProdutos() async {
    try {
      final file = await _localFile;
      if (!file.existsSync()) {
        return [];
      }
      String contents = await file.readAsString();
      return json.decode(contents);
    } catch (e) {
      return [];
    }
  }

  Future<File> writeProdutos(List produtos) async {
    final file = await _localFile;
    return file.writeAsString(json.encode(produtos));
  }

  Future<void> salvarProduto() async {
    if (_formKey.currentState!.validate()) {
      // Cria o mapa do produto
      Map<String, dynamic> produto = {
        'id': 0,
        'codigo': _codigoController.text,
        'cor': _corController.text,
        'descricao': _descricaoController.text,
        'imagens': imagensBase64,
      };

      List<dynamic> produtos = await readProdutos();

      if (editando) {
        if (_codigoController.text != codigoOriginal &&
            produtos.any((p) => p['codigo'] == _codigoController.text)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Já existe um produto com esse código!")),
          );
          return;
        }

        int index = produtos.indexWhere((p) => p['id'] == produto['id']);
        produtos[index] = produto;
      } else {
        if (produtos.any((p) => p['codigo'] == produto['codigo'])) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Já existe um produto com esse código!")),
          );
          return;
        }

        produto['id'] = produtos.length;
        produtos.add(produto);
      }
      await writeProdutos(produtos);
      Navigator.pop(context);
    }
  }

  Future<void> capturarImagem() async {
    final picker = ImagePicker();
    final XFile? imagem = await picker.pickImage(source: ImageSource.camera);
    if (imagem != null) {
      final bytes = await imagem.readAsBytes();
      String base64Image = base64Encode(bytes);
      setState(() {
        imagensBase64.add(base64Image);
      });
    }
  }

  void exibirImagemDialog(String imageBase64) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          color: Colors.black,
          padding: EdgeInsets.all(10),
          child: InteractiveViewer(
            child: Image.memory(
              base64Decode(imageBase64),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    ),
  );
}

void confirmarExclusao() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Confirmar Exclusão"),
      content: Text("Tem certeza que deseja excluir este produto?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Cancelar"),
        ),
        TextButton(
          onPressed: () => excluirProduto(),
          child: Text("Excluir", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

Future<void> excluirProduto() async {
  List<dynamic> produtos = await readProdutos();
  produtos.removeWhere((p) => p['codigo'] == codigoOriginal);
  await writeProdutos(produtos);

  Navigator.of(context).pop(); // Fecha o diálogo
  Navigator.of(context).pop(); // Volta para a tela anterior
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.produto != null ? 'Editar Produto' : 'Novo Produto'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _codigoController,
                  decoration: InputDecoration(labelText: 'Código'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe o código';
                    }
                    // Validação para aceitar apenas números
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'O código deve conter apenas números';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _corController,
                  decoration: InputDecoration(labelText: 'Cor'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe a cor';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descricaoController,
                  decoration: InputDecoration(labelText: 'Descrição'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe a descrição';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: capturarImagem,
                  child: Text('Capturar Imagem'),
                ),
                SizedBox(height: 10),
                // Exibição das imagens capturadas
                imagensBase64.isNotEmpty
                    ? Wrap(
                        spacing: 10,
                        children: imagensBase64.map((imgBase64) {
                          return GestureDetector(
                            onTap: () => exibirImagemDialog(imgBase64),
                            child: Image.memory(
                              base64Decode(imgBase64),
                              width: 100,
                              height: 100,
                            ),
                          );
                        }).toList(),
                      )
                    : Container(),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: salvarProduto,
                  child: Text('Salvar Produto'),
                ),
                SizedBox(height: 20),
                if (editando) 
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: confirmarExclusao,
                    child: Text('Excluir Produto', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}