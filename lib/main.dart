import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

void main() => runApp(const MyApp());

class Contact {
  int? id;
  String name, phone, email, address;
  bool isFavorite;

  Contact({
    this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'address': address,
    'favorite': isFavorite ? 1 : 0,
  };

  factory Contact.fromMap(Map<String, dynamic> m) => Contact(
    id: m['id'],
    name: m['name'],
    phone: m['phone'],
    email: m['email'],
    address: m['address'],
    isFavorite: m['favorite'] == 1,
  );
}

class DB {
  static Database? _db;

  static Future<Database> get db async {
    _db ??= await openDatabase(
      p.join(await getDatabasesPath(), 'contacts.db'),
      version: 1,
      onCreate: (d, v) => d.execute(
        'CREATE TABLE contacts('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'name TEXT, phone TEXT, email TEXT, address TEXT, '
            'favorite INTEGER DEFAULT 0)',
      ),
    );
    return _db!;
  }

  static Future<List<Contact>> getAll(
      {String search = '', bool favOnly = false}) async {
    final d = await db;
    final rows = await d.query(
      'contacts',
      where: favOnly ? 'name LIKE ? AND favorite = 1' : 'name LIKE ?',
      whereArgs: ['%$search%'],
      orderBy: 'name COLLATE NOCASE',
    );
    return rows.map((r) => Contact.fromMap(r)).toList();
  }

  // CREATE
  static Future<void> insert(Contact c) async {
    final d = await db;
    final map = c.toMap();
    map.remove('id');
    await d.insert('contacts', map);
  }
  static Future<void> update(Contact c) async {
    final d = await db;
    await d.update('contacts', c.toMap(), where: 'id = ?', whereArgs: [c.id]);
  }

  // DELETE
  static Future<void> delete(int id) async {
    final d = await db;
    await d.delete('contacts', where: 'id = ?', whereArgs: [id]);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contacts',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Contact> contacts = [];
  String search = '';
  bool favOnly = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final data = await DB.getAll(search: search, favOnly: favOnly);
    setState(() => contacts = data);
  }

  Future<void> openForm([Contact? c]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ContactForm(contact: c)),
    );
    load();
  }

  Future<void> confirmDelete(Contact c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete contact?'),
        content: Text('Remove ${c.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await DB.delete(c.id!);
      load();
    }
  }

  Future<void> toggleFav(Contact c) async {
    c.isFavorite = !c.isFavorite;
    await DB.update(c);
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(favOnly ? 'Favorite Contacts' : 'My Contacts'),
        actions: [
          IconButton(
            tooltip: 'Show favorites only',
            icon: Icon(favOnly ? Icons.star : Icons.star_border),
            onPressed: () {
              favOnly = !favOnly;
              load();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) {
                search = v;
                load();
              },
            ),
          ),
        ),
      ),
      body: contacts.isEmpty
          ? const Center(child: Text('No contacts found'))
          : ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, i) {
          final c = contacts[i];
          return Card(
            margin:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            child: ListTile(
              onTap: () => openForm(c),
              leading: CircleAvatar(
                child: Text(
                  c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                ),
              ),
              title: Text(c.name),
              subtitle: Text('${c.phone}\n${c.email}'),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      c.isFavorite ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () => toggleFav(c),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => confirmDelete(c),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
class ContactForm extends StatefulWidget {
  final Contact? contact;
  const ContactForm({super.key, this.contact});

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController name, phone, email, address;
  bool fav = false;

  @override
  void initState() {
    super.initState();
    final c = widget.contact;
    name = TextEditingController(text: c?.name ?? '');
    phone = TextEditingController(text: c?.phone ?? '');
    email = TextEditingController(text: c?.email ?? '');
    address = TextEditingController(text: c?.address ?? '');
    fav = c?.isFavorite ?? false;
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;
    final c = Contact(
      id: widget.contact?.id,
      name: name.text.trim(),
      phone: phone.text.trim(),
      email: email.text.trim(),
      address: address.text.trim(),
      isFavorite: fav,
    );
    if (c.id == null) {
      await DB.insert(c);
    } else {
      await DB.update(c);
    }
    if (mounted) Navigator.pop(context);
  }

  Widget field(TextEditingController ctrl, String label, IconData icon,
      {TextInputType? type, bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator: (v) =>
        required && (v == null || v.trim().isEmpty) ? 'Required' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.contact != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Edit Contact' : 'Add Contact')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              field(name, 'Name', Icons.person),
              field(phone, 'Phone Number', Icons.phone,
                  type: TextInputType.phone),
              field(email, 'Email', Icons.email,
                  type: TextInputType.emailAddress),
              field(address, 'Address', Icons.home, required: false),
              SwitchListTile(
                title: const Text('Favorite'),
                value: fav,
                onChanged: (v) => setState(() => fav = v),
              ),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: save,
                child: Text(editing ? 'Update' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}