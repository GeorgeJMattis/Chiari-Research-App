
/**
    Has functions to start and stop pressure sampling, as well as a function to take a single read of the pressure sensor. The actual implementation of these functions will depend on the specific hardware and software being used for pressure sensing, but this class serves as a template for how to structure the code for pressure sampling in the app.
 */

protocol PressureSampling {



    func startSampling() async
    
    func stopSampling() async
    
    func singleRead() async

}

