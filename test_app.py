from app import app
from flask_testing import TestCase

class TestFlaskApi(TestCase):
    def create_app(self):
        app.config['TESTING'] = True
        return app

    def test_api_route(self):
        response = self.client.get('/api')
        self.assertEqual(response.status_code, 200)

if __name__ == '__main__':
    import unittest
    unittest.main()
