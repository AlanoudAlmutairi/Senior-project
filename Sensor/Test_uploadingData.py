import unittest
from uploadingData import read_sensor_data, send_to_supabase

class MyTestCase(unittest.TestCase):
    def test_send_to_supabase(self):
        test_data = read_sensor_data()
        self.assertIsNotNone(test_data)

        response = send_to_supabase(test_data)
        self.assertEquals(response , "Data stored successfully")



if __name__ == '__main__':
    unittest.main()





    