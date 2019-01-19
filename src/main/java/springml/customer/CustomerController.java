package springml.customer;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import springml.customer.dao.CustomerDAO;

@RestController
@RequestMapping("/customer")
public class CustomerController {
	
	private boolean serveRequests;
	@Autowired
	private CustomerDAO customerDAO;
	
	@RequestMapping(value="/{email}", method = RequestMethod.GET)
	public Customer getCustomer(@PathVariable String email) throws Exception {
		Customer customer = customerDAO.getCustomerByEmail(email);
		return customer;
	}
	
	@RequestMapping(value="/all", method = RequestMethod.GET)
	public List<Customer> getAllCustomers() throws Exception {
		List<Customer> customers = customerDAO.getAllCustomers();
		return customers;
	}
	
	@RequestMapping(value="/create", method = RequestMethod.PUT)
	public void create(@RequestBody Customer customer) throws Exception {
		System.out.println("inside create");
		customerDAO.createCustomer(customer);
		System.out.println("Following Customer is created");
		System.out.println(customer);
	}
	
	@RequestMapping(value="/update", method = RequestMethod.POST)
	public void update(@RequestBody Customer customer) throws Exception {
		customerDAO.updateCustomer(customer);
		System.out.println("Following Customer is updated");
		System.out.println(customer);
	}
	
	@RequestMapping(value="/delete", method = RequestMethod.DELETE)
	public void delete(@RequestBody Customer customer) throws Exception {
		customerDAO.deleteCustomer(customer);
		System.out.println("Following Customer is deleted");
		System.out.println(customer);
	}
	
	@RequestMapping(value="/ready", method = RequestMethod.GET)
	public ResponseEntity<?> isReady() {
		if (serveRequests) {
			return ResponseEntity.ok().body("Application is ready to serve"); 
		} else {
			throw new RuntimeException("Application is not ready yet");
		}
	}
	
	@RequestMapping(value="/releaseAppResources", method = RequestMethod.GET)
	public void releaseAppResources() {
		//TODO: Add code below to release application resources
	}
	@EventListener(ApplicationReadyEvent.class)
	public void readyToServeRequests() {
		this.serveRequests = true;
	}
}
