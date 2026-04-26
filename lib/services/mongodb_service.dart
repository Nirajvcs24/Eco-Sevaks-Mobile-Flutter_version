import 'package:mongo_dart/mongo_dart.dart';
import 'dart:developer';

class MongoService {
  // Replace this with your actual MongoDB connection string
  static const String mongoUrl = "mongodb+srv://omkarpmath_db_user:9SMX5WzFLsZkPLV1@eco-sevaks.larzp3o.mongodb.net/?appName=Eco-Sevaks";
  
  static Db? _db;
  static bool _isConnected = false;

  static Db? get db => _db;
  static bool get isConnected => _isConnected;

  /// Initializes the connection to MongoDB
  static Future<void> connect() async {
    if (_isConnected) return;

    try {
      _db = await Db.create(mongoUrl);
      await _db!.open();
      _isConnected = true;
      log("Successfully connected to MongoDB");
    } catch (e) {
      log("Error connecting to MongoDB: $e");
      _isConnected = false;
      rethrow;
    }
  }

  /// Closes the connection
  static Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _isConnected = false;
      log("MongoDB connection closed");
    }
  }

  static DbCollection getCollection(String collectionName) {
    if (!_isConnected || _db == null) {
      throw Exception("Database not connected. Call connect() first.");
    }
    return _db!.collection(collectionName);
  }

  /// Fetches all documents from a collection
  static Future<List<Map<String, dynamic>>> fetchAll(String collectionName) async {
    try {
      final collection = getCollection(collectionName);
      return await collection.find().toList();
    } catch (e) {
      log("Error fetching from $collectionName: $e");
      return [];
    }
  }

  /// Inserts a document into a collection
  static Future<void> insert(String collectionName, Map<String, dynamic> data) async {
    try {
      final collection = getCollection(collectionName);
      await collection.insertOne(data);
      log("Document inserted into $collectionName");
    } catch (e) {
      log("Error inserting into $collectionName: $e");
      rethrow;
    }
  }

  /// Updates a document by ID
  static Future<void> update(String collectionName, String id, Map<String, dynamic> data) async {
    try {
      final collection = getCollection(collectionName);
      var modifier = modify;
      data.forEach((key, value) => modifier.set(key, value));
      await collection.updateOne(where.id(ObjectId.parse(id)), modifier);
      log("Document $id updated in $collectionName");
    } catch (e) {
      log("Error updating $id in $collectionName: $e");
      rethrow;
    }
  }

  /// Deletes a document by ID
  static Future<void> delete(String collectionName, String id) async {
    try {
      final collection = getCollection(collectionName);
      await collection.deleteOne(where.id(ObjectId.parse(id)));
      log("Document $id deleted from $collectionName");
    } catch (e) {
      log("Error deleting $id from $collectionName: $e");
      rethrow;
    }
  }

  /// Helper to test the connection and fetch a sample document
  static Future<void> testConnection() async {
    try {
      await connect();
      // Try to list collections as a simple test
      final collections = await _db!.getCollectionNames();
      log("Available collections: $collections");
    } catch (e) {
      log("Test connection failed: $e");
    }
  }
}
