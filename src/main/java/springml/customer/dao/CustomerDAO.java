package springml.customer.dao;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import springml.customer.Customer;
@Repository
public class CustomerDAO {
	@Autowired
	private JdbcTemplate jdbcTemplate;
	
	public List<Customer> getAllCustomers() throws Exception {
		return jdbcTemplate.query("select * from profile", new CustomerMapper());
		
	}
	
	public Customer getCustomerByEmail(String email) throws Exception {
		String sql = "select * from profile where email = ?";
		Customer customer = (Customer)jdbcTemplate.queryForObject(
				sql, new Object[] { email }, new CustomerMapper());
		return customer;
	}
	
	public void createCustomer(Customer customer) throws Exception {
		Object[] params = new Object[] { customer.getEmail(), customer.getFirstName(), customer.getLastName(), customer.getAddress() };
		jdbcTemplate.update("insert into profile(email, firstName, lastName, address) values(?, ?, ?, ?)", params);
		
	}
	
	public void updateCustomer(Customer customer) throws Exception {
		Object[] params = new Object[] { customer.getFirstName(), customer.getLastName(), customer.getAddress() , customer.getEmail()};
		jdbcTemplate.update("update profile set firstName =?, lastName = ?, address = ? where email = ?", params);
	}
	
	public void deleteCustomer(Customer customer) throws Exception {
		Object[] params = new Object[] {customer.getEmail()};
		jdbcTemplate.update("delete from profile where email = ?", params);
	}
}
