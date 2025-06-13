import '../models/company_model.dart';

class DatabaseService {
  // Simulate database call for localities
  Future<List<String>> getLocalities() async {
    // Replace this with your actual database call
    await Future.delayed(const Duration(seconds: 1)); // Simulate loading
    
    // Return localities from your database
    return [
      'Marathahalli',
      'MG Layout', 
      'Whitefield',
      'Koramangala',
      'Bellandur',
      'Electronic City',
      'Indiranagar',
      'HSR Layout'
    ];
  }

  // Simulate database call for companies
  Future<List<Company>> getCompanies() async {
    // Replace this with your actual database call
    await Future.delayed(const Duration(seconds: 1)); // Simulate loading
    
    // Return companies from your database
    return [
      Company(
        id: '1',
        name: 'Tech Solutions Pvt Ltd',
        address: 'The Skyline • Seoul Plaza Rd',
      ),
      Company(
        id: '2',
        name: 'Innovation Hub Corp',
        address: 'Tech Park • Whitefield',
      ),
      Company(
        id: '3',
        name: 'Digital Dynamics Ltd',
        address: 'Business Hub • Koramangala',
      ),
    ];
  }
}
