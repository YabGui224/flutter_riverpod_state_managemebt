# Flutter Riverpod - Guide Complet

## Table des matières
1. [Création de Providers](#création-de-providers)
2. [Configuration du ProviderScope](#configuration-du-providerscope)
3. [Branchement des Consumers](#branchement-des-consumers)
4. [Écouter les Providers dans l'UI](#écouter-les-providers-dans-lui)
5. [Création de Notifiers](#création-de-notifiers)
6. [Utilisation dans l'UI](#utilisation-dans-lui)
7. [Instructions de démarrage](#instructions-de-démarrage)

---

## Création de Providers

### Méthode Manuelle

#### Provider Simple
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider simple pour une valeur
final messageProvider = Provider<String>((ref) {
  return 'Hello from Riverpod!';
});

// Provider pour un objet
final userProvider = Provider<User>((ref) {
  return User(name: 'John', age: 25);
});
```

#### StateProvider
```dart
// Pour des valeurs simples qui peuvent changer
final counterProvider = StateProvider<int>((ref) {
  return 0;
});

final isDarkModeProvider = StateProvider<bool>((ref) {
  return false;
});
```

#### FutureProvider
```dart
// Pour des opérations asynchrones
final todosProvider = FutureProvider<List<Todo>>((ref) async {
  final response = await http.get(Uri.parse('https://api.example.com/todos'));
  return parseTodos(response.body);
});
```

#### StreamProvider
```dart
// Pour des streams de données
final messagesProvider = StreamProvider<List<Message>>((ref) {
  return FirebaseFirestore.instance
      .collection('messages')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Message.fromDoc(doc)).toList());
});
```

### Méthode avec Annotations (Code Generation)

#### Installation des dépendances
```yaml
dependencies:
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0

dev_dependencies:
  build_runner: ^2.4.0
  riverpod_generator: ^2.3.0
```

#### Provider Simple avec @riverpod
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@riverpod
String message(MessageRef ref) {
  return 'Hello from Generated Provider!';
}

@riverpod
User user(UserRef ref) {
  return User(name: 'Jane', age: 30);
}
```

#### Provider Asynchrone avec @riverpod
```dart
@riverpod
Future<List<Todo>> todos(TodosRef ref) async {
  final response = await http.get(Uri.parse('https://api.example.com/todos'));
  return parseTodos(response.body);
}

@riverpod
Stream<List<Message>> messages(MessagesRef ref) {
  return FirebaseFirestore.instance
      .collection('messages')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Message.fromDoc(doc)).toList());
}
```

#### Commande pour générer le code
```bash
dart run build_runner watch
# ou
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Configuration du ProviderScope

### Dans main.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    // Wrapper toute l'application avec ProviderScope
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Riverpod Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}
```

### ProviderScope avec des overrides (pour les tests)
```dart
void main() {
  runApp(
    ProviderScope(
      overrides: [
        // Override pour les tests ou configurations spécifiques
        messageProvider.overrideWith((ref) => 'Test message'),
      ],
      child: const MyApp(),
    ),
  );
}
```

---

## Branchement des Consumers

### ConsumerWidget (remplace StatelessWidget)
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Accès au provider via ref
    final message = ref.watch(messageProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Consumer Widget')),
      body: Center(
        child: Text(message),
      ),
    );
  }
}
```

### ConsumerStatefulWidget (remplace StatefulWidget)
```dart
class CounterPage extends ConsumerStatefulWidget {
  const CounterPage({super.key});

  @override
  ConsumerState<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends ConsumerState<CounterPage> {
  @override
  void initState() {
    super.initState();
    // Accès à ref dans initState
    // ref.read(someProvider); // Ne pas utiliser watch ici
  }

  @override
  Widget build(BuildContext context) {
    // Accès au provider avec ref
    final counter = ref.watch(counterProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Count: $counter',
              style: const TextStyle(fontSize: 24),
            ),
            ElevatedButton(
              onPressed: () {
                // Modifier la valeur
                ref.read(counterProvider.notifier).state++;
              },
              child: const Text('Increment'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Consumer Widget (pour usage local)
```dart
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Consumer(
        builder: (context, ref, child) {
          final user = ref.watch(userProvider);
          
          return Center(
            child: Column(
              children: [
                Text('Name: ${user.name}'),
                Text('Age: ${user.age}'),
                if (child != null) child,
              ],
            ),
          );
        },
        // child est rebuild seulement si le widget parent rebuild
        child: const Text('This does not rebuild'),
      ),
    );
  }
}
```

---

## Écouter les Providers dans l'UI

### ref.watch() - Rebuild automatique
```dart
class WatchExample extends ConsumerWidget {
  const WatchExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch rebuilds le widget quand la valeur change
    final counter = ref.watch(counterProvider);
    
    return Text('Counter: $counter');
  }
}
```

### ref.read() - Lecture unique (events, callbacks)
```dart
class ReadExample extends ConsumerWidget {
  const ReadExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        // read pour les actions ponctuelles
        // NE REBUILD PAS le widget
        ref.read(counterProvider.notifier).state++;
      },
      child: const Text('Increment'),
    );
  }
}
```

### ref.listen() - Écouter sans rebuild (navigation, snackbars)
```dart
class ListenExample extends ConsumerWidget {
  const ListenExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // listen pour les side effects
    ref.listen<int>(counterProvider, (previous, next) {
      if (next >= 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Counter reached 10!')),
        );
      }
    });

    final counter = ref.watch(counterProvider);
    
    return Text('Counter: $counter');
  }
}
```

### Gestion des états asynchrones (FutureProvider)
```dart
class AsyncExample extends ConsumerWidget {
  const AsyncExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTodos = ref.watch(todosProvider);
    
    return asyncTodos.when(
      data: (todos) => ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          return ListTile(title: Text(todos[index].title));
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
```

---

## Création de Notifiers

### StateNotifier (méthode manuelle)
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Modèle
class Todo {
  final String id;
  final String title;
  final bool completed;

  Todo({
    required this.id,
    required this.title,
    this.completed = false,
  });

  Todo copyWith({String? title, bool? completed}) {
    return Todo(
      id: id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
    );
  }
}

// StateNotifier pour gérer la liste
class TodosNotifier extends StateNotifier<List<Todo>> {
  TodosNotifier() : super([]);

  // Ajouter un todo
  void addTodo(String title) {
    final newTodo = Todo(
      id: DateTime.now().toString(),
      title: title,
    );
    state = [...state, newTodo];
  }

  // Supprimer un todo
  void removeTodo(String id) {
    state = state.where((todo) => todo.id != id).toList();
  }

  // Toggle completed
  void toggleCompleted(String id) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          todo.copyWith(completed: !todo.completed)
        else
          todo,
    ];
  }

  // Modifier le titre
  void updateTitle(String id, String newTitle) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          todo.copyWith(title: newTitle)
        else
          todo,
    ];
  }

  // Charger des todos
  Future<void> loadTodos() async {
    // Simulation d'un appel API
    await Future.delayed(const Duration(seconds: 1));
    state = [
      Todo(id: '1', title: 'Learn Flutter'),
      Todo(id: '2', title: 'Learn Riverpod'),
    ];
  }
}

// Provider pour le notifier
final todosNotifierProvider = StateNotifierProvider<TodosNotifier, List<Todo>>((ref) {
  return TodosNotifier();
});
```

### Notifier avec @riverpod (Code Generation)
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'todos_notifier.g.dart';

@riverpod
class TodosNotifier extends _$TodosNotifier {
  @override
  List<Todo> build() {
    // État initial
    return [];
  }

  void addTodo(String title) {
    final newTodo = Todo(
      id: DateTime.now().toString(),
      title: title,
    );
    state = [...state, newTodo];
  }

  void removeTodo(String id) {
    state = state.where((todo) => todo.id != id).toList();
  }

  void toggleCompleted(String id) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          todo.copyWith(completed: !todo.completed)
        else
          todo,
    ];
  }
}
```

### AsyncNotifier pour opérations asynchrones
```dart
@riverpod
class AsyncTodosNotifier extends _$AsyncTodosNotifier {
  @override
  Future<List<Todo>> build() async {
    // Chargement initial
    return await _fetchTodos();
  }

  Future<List<Todo>> _fetchTodos() async {
    final response = await http.get(Uri.parse('https://api.example.com/todos'));
    return parseTodos(response.body);
  }

  Future<void> addTodo(String title) async {
    // État de chargement
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      final newTodo = Todo(id: DateTime.now().toString(), title: title);
      await http.post(
        Uri.parse('https://api.example.com/todos'),
        body: newTodo.toJson(),
      );
      
      return [...state.value!, newTodo];
    });
  }

  Future<void> removeTodo(String id) async {
    state = await AsyncValue.guard(() async {
      await http.delete(Uri.parse('https://api.example.com/todos/$id'));
      return state.value!.where((todo) => todo.id != id).toList();
    });
  }
}
```

---

## Utilisation dans l'UI

### Exemple complet avec liste de Todos
```dart
class TodosPage extends ConsumerWidget {
  const TodosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todosNotifierProvider);
    final todosNotifier = ref.read(todosNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(context, todosNotifier),
          ),
        ],
      ),
      body: todos.isEmpty
          ? const Center(child: Text('No todos yet'))
          : ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return ListTile(
                  leading: Checkbox(
                    value: todo.completed,
                    onChanged: (_) {
                      todosNotifier.toggleCompleted(todo.id);
                    },
                  ),
                  title: Text(
                    todo.title,
                    style: TextStyle(
                      decoration: todo.completed
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      todosNotifier.removeTodo(todo.id);
                    },
                  ),
                );
              },
            ),
    );
  }

  void _showAddDialog(BuildContext context, TodosNotifier notifier) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Todo'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter todo title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                notifier.addTodo(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
```

### Providers dérivés (computed providers)
```dart
// Filtrer les todos complétés
final completedTodosProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todosNotifierProvider);
  return todos.where((todo) => todo.completed).toList();
});

// Compter les todos
final todosCountProvider = Provider<int>((ref) {
  final todos = ref.watch(todosNotifierProvider);
  return todos.length;
});

// Avec annotation
@riverpod
List<Todo> completedTodos(CompletedTodosRef ref) {
  final todos = ref.watch(todosNotifierProvider);
  return todos.where((todo) => todo.completed).toList();
}

@riverpod
int todosCount(TodosCountRef ref) {
  final todos = ref.watch(todosNotifierProvider);
  return todos.length;
}
```

### Utilisation dans l'UI
```dart
class TodosStats extends ConsumerWidget {
  const TodosStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalCount = ref.watch(todosCountProvider);
    final completedTodos = ref.watch(completedTodosProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Total: $totalCount'),
            Text('Completed: ${completedTodos.length}'),
            Text('Remaining: ${totalCount - completedTodos.length}'),
          ],
        ),
      ),
    );
  }
}
```

---

## Instructions de démarrage

### Prérequis
- Flutter SDK (version >= 3.0.0)
- Dart SDK (version >= 3.0.0)

### Installation

1. **Cloner le repository**
```bash
git clone <url-du-repo>
cd <nom-du-projet>
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Générer le code (si utilisation des annotations)**
```bash
# En mode watch (génération automatique)
dart run build_runner watch

# Ou en une seule fois
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **Lancer l'application**
```bash
flutter run
```

### Structure du projet
```
lib/
├── main.dart                 # Point d'entrée avec ProviderScope
├── models/                   # Modèles de données
│   └── todo.dart
├── providers/                # Providers et Notifiers
│   ├── todos_provider.dart
│   └── todos_provider.g.dart # Généré automatiquement
├── screens/                  # Pages de l'application
│   ├── home_page.dart
│   └── todos_page.dart
└── widgets/                  # Widgets réutilisables
    └── todo_item.dart
```

### Dépendances principales
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.0
  riverpod_generator: ^2.3.0
  flutter_lints: ^2.0.0
```

### Commandes utiles

**Nettoyer le cache**
```bash
flutter clean
flutter pub get
```

**Regénérer tous les fichiers**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Analyser le code**
```bash
flutter analyze
```

**Formater le code**
```bash
dart format .
```

### Ressources
- [Documentation officielle Riverpod](https://riverpod.dev)
- [Net Ninja - Flutter Riverpod Tutorial](https://www.youtube.com/playlist?list=PL4cUxeGkcC9hOedy4Gp3c-GqUPoIzGD2r)
- [Flutter Documentation](https://docs.flutter.dev)

### Dépannage

**Erreur: "A package may not list itself as a dependency"**
- Vérifiez que le `name:` dans pubspec.yaml n'est pas "flutter_riverpod"

**Les fichiers .g.dart ne se génèrent pas**
- Vérifiez que `part 'fichier.g.dart';` est bien présent en haut du fichier
- Lancez `dart run build_runner build --delete-conflicting-outputs`

**Hot reload ne fonctionne pas avec les providers**
- Relancez complètement l'application (hot restart)
- Les changements dans les providers nécessitent parfois un restart complet

---

## Bonnes pratiques

1. **Organisation des providers**
    - Grouper les providers par fonctionnalité
    - Utiliser des fichiers séparés pour chaque ensemble de providers

2. **Nommage**
    - Suffixer les providers avec `Provider` (ex: `todosProvider`)
    - Suffixer les notifiers avec `Notifier` (ex: `TodosNotifier`)

3. **Performance**
    - Utiliser `ref.watch()` uniquement pour les données affichées
    - Utiliser `ref.read()` pour les callbacks et événements
    - Créer des providers dérivés pour éviter les recalculs

4. **Tests**
    - Les providers sont facilement testables avec `ProviderContainer`
    - Utiliser `overrides` pour mocker les dépendances

5. **Code generation vs manuel**
    - Préférer les annotations pour les nouveaux projets
    - Plus type-safe et moins de boilerplate
    - Génération automatique du code