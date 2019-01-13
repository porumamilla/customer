package springml.customer;

import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/customer")
public class CustomerController {
	
	@RequestMapping(value="/{email}", method = RequestMethod.GET)
	public Customer getCustomer(@PathVariable String email) {
		Customer customer = new Customer();
		
		customer.setEmail("raghu.rao@springml.com");
		customer.setFirstName("Raghu");
		customer.setLastName("Porumamilla");
		customer.setAddress("7 Arbor Cir Cincinnati OH 45255");
		return customer;
	}
	
	@RequestMapping(value="/", method = RequestMethod.PUT)
	public void create(@RequestBody Customer customer) {
		System.out.println("Following Customer is created");
		System.out.println(customer);
	}
	
	@RequestMapping(value="/", method = RequestMethod.POST)
	public void update(@RequestBody Customer customer) {
		System.out.println("Following Customer is updated");
		System.out.println(customer);
	}
	
	@RequestMapping(value="/", method = RequestMethod.DELETE)
	public void delete(@RequestBody Customer customer) {
		System.out.println("Following Customer is deleted");
		System.out.println(customer);
	}
}
