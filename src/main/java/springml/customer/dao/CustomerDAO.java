package springml.customer.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import springml.customer.Customer;
import springml.customer.config.ApplicationConfig;
@Repository
public class CustomerDAO {
	
	@Autowired
	private ApplicationConfig appConfig;
	
	private Connection getConnection() throws Exception {
		String databaseName = appConfig.getMysqldb().getDatabase();
		String instanceConnectionName = appConfig.getMysqldb().getProject() + ":" + 
										appConfig.getMysqldb().getRegion() + ":" +
										appConfig.getMysqldb().getInstance();
		String username = appConfig.getMysqldb().getUser();
		String password = appConfig.getMysqldb().getPassword();
		String jdbcUrl = String.format(
				"jdbc:mysql://google/%s?cloudSqlInstance=%s"
						+ "&socketFactory=com.google.cloud.sql.mysql.SocketFactory&useSSL=false",
				databaseName, instanceConnectionName);

		return DriverManager.getConnection(jdbcUrl, username, password);
	}

	public List<Customer> getAllCustomers() throws Exception {
		List<Customer> customers = new ArrayList<Customer>();
		
		Connection con = null;
		try {
			con = getConnection();
			PreparedStatement ps = con.prepareStatement("select * from profile");
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				Customer customer = new Customer();
				customer.setEmail(rs.getString("email"));
				customer.setFirstName(rs.getString("firstName"));
				customer.setLastName(rs.getString("lastName"));
				customer.setAddress(rs.getString("address"));
				customers.add(customer);
			}
		} finally {
			if (con != null) {
				con.close();
			}
		}
		return customers;
	}
	public Customer getCustomerByEmail(String email) throws Exception {
		Customer customer = new Customer();
		Connection con = null;
		try {
			con = getConnection();
			PreparedStatement ps = con.prepareStatement("select * from profile where email = ?");
			ps.setString(1, email);
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				customer.setEmail(rs.getString("email"));
				customer.setFirstName(rs.getString("firstName"));
				customer.setLastName(rs.getString("lastName"));
				customer.setAddress(rs.getString("address"));
			}
		} finally {
			if (con != null) {
				con.close();
			}
		}
		return customer;
	}
	
	public void createCustomer(Customer customer) throws Exception {
		Connection con = null;
		try {
			con = getConnection();
			PreparedStatement ps = con.prepareStatement("insert into profile(email, firstName, lastName, address) values(?, ?, ?, ?)");
			ps.setString(1, customer.getEmail());
			ps.setString(2, customer.getFirstName());
			ps.setString(3, customer.getLastName());
			ps.setString(4, customer.getAddress());
			ps.executeUpdate();
		} finally {
			if (con != null) {
				con.close();
			}
		}
	}
	
	public void updateCustomer(Customer customer) throws Exception {
		Connection con = null;
		try {
			con = getConnection();
			PreparedStatement ps = con.prepareStatement("update profile set firstName =?, lastName = ?, address = ? where email = ?");
			
			ps.setString(1, customer.getFirstName());
			ps.setString(2, customer.getLastName());
			ps.setString(3, customer.getAddress());
			
			ps.setString(4, customer.getEmail());
			ps.executeUpdate();
		} finally {
			if (con != null) {
				con.close();
			}
		}
	}
	
	public void deleteCustomer(Customer customer) throws Exception {
		Connection con = null;
		try {
			con = getConnection();
			PreparedStatement ps = con.prepareStatement("delete from profile where email = ?");
			ps.setString(1, customer.getEmail());
			ps.executeUpdate();
		} finally {
			if (con != null) {
				con.close();
			}
		}
	}
	
	public static void main(String[] args) throws Exception {
		CustomerDAO customerDAO = new CustomerDAO();
		System.out.println(customerDAO.getCustomerByEmail("porumamilla_raghu@yahoo.com"));
	}
}
