package de.digitalemil.mesonautsgym;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.Writer;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.FileHandler;
import java.util.logging.Handler;
import java.util.logging.Logger;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import javax.xml.bind.JAXBException;
import org.dmg.pmml.FieldName;
import org.dmg.pmml.IOUtil;
import org.dmg.pmml.PMML;
import org.jpmml.evaluator.FieldValue;
import org.jpmml.evaluator.ModelEvaluator;
import org.jpmml.evaluator.ModelEvaluatorFactory;
import org.jpmml.evaluator.NodeClassificationMap;
import org.jpmml.manager.PMMLManager;
import org.json.JSONException;
import org.json.JSONObject;
import org.xml.sax.SAXException;
import java.net.URLDecoder;
import java.io.PrintWriter;

/**
 */
public class MesonautsGym extends HttpServlet {
	private static final long serialVersionUID = 1L;
	public static Logger hrlogger;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public MesonautsGym() {
		super();
	}

	@Override
	public void init(ServletConfig cfg) throws ServletException {
		super.init(cfg);


	hrlogger = Logger
					.getLogger("de.digitalemil.mesonautsgym.heartrates");

			try {
				Handler fileHandler = new FileHandler("logs/hrdata.out");
				LogFormatter formatter = new LogFormatter();
				fileHandler.setFormatter(formatter);
				hrlogger.addHandler(fileHandler);

			} catch (SecurityException e) {
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}

protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
			}


	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {

		// Handling Heartrate
		BufferedReader reader = request.getReader();
		PrintWriter writer = response.getWriter();

		StringBuffer json = new StringBuffer();
		JSONObject jobj = null;

		do {
			String line = reader.readLine();
			if (line == null)
				break;
			json.append(line + "\n");
		} while (true);
		String jsonstring= json.toString();
		jsonstring= URLDecoder.decode(jsonstring.replace("+", "%2B"), "UTF-8").replace("%2B", "+");
	
	//	System.out.println("In: "+jsonstring);
	
	//	if ( hrlogger != null)
	//		hrlogger.severe(jsonstring);

		String color= "0x80FFFFFF";
		try {
			jobj = new JSONObject(jsonstring);
			System.out.println("HR: "+jobj.get("heartrate"));
	
			Object modelobj= jobj.get("model");
			
			if(modelobj!= null) {
				String model= modelobj.toString();
				model= model.replace("'", "\"");
	//		System.out.println("model: "+model);
		
				ModelEvaluator m= setModelString(model);
				color= getColor(m, model, new Double(jobj.get("heartrate").toString()));
			}
		} catch (Exception e) {	
			e.printStackTrace();
			System.out.println("Error: "+e);
		}
		System.out.println("Color: "+color);
		writer.print(color);
	}

	// Needed to run without Hadoop
	//
	private static ModelEvaluator createModelEvaluator(String modelString)
			throws SAXException, JAXBException {
		ModelEvaluator m= null;
				try {
		InputStream is = new ByteArrayInputStream(modelString.getBytes());

		PMML pmml = IOUtil.unmarshal(is);

		PMMLManager pmmlManager = new PMMLManager(pmml);

		 m = (ModelEvaluator) pmmlManager.getModelManager(null,
				ModelEvaluatorFactory.getInstance());
				}
				catch(Exception e) {
				}
		return m;

	//	System.out.println("New model created for: " + modelEvaluator);
	}

	public String getColor(ModelEvaluator modelEvaluator, String modelString,  Double hr) {
		if (modelString == null || modelString.length() <= 0
				|| modelEvaluator == null)
			return "0x80FFFFFF";
		Map<FieldName, FieldValue> arguments = new LinkedHashMap<FieldName, FieldValue>();
		List<FieldName> activeFields = modelEvaluator.getActiveFields();
		for (FieldName activeField : activeFields) {
			System.out.println("ActiveField: "+activeField+" "+hr);
			FieldValue activeValue = modelEvaluator.prepare(activeField, hr);
			arguments.put(activeField, activeValue);
		}

		Map<FieldName, ?> results = modelEvaluator.evaluate(arguments);

		FieldName targetName = modelEvaluator.getTargetField();
		Object targetValue = results.get(targetName);

		NodeClassificationMap nodeMap = (NodeClassificationMap) targetValue;
		return nodeMap.getResult();
	}

	public static ModelEvaluator setModelString(String s) {
		try {
			return createModelEvaluator(s);
		} catch (SAXException e) {
			e.printStackTrace();
		} catch (JAXBException e) {
			e.printStackTrace();
		}
		return null;
	}
}
