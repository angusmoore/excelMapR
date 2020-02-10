import java.io.InputStream;
import java.io.IOException;
 
import java.util.List;
import java.util.ArrayList;

import org.apache.poi.hssf.model.InternalWorkbook;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory; 
import org.apache.poi.xssf.model.ExternalLinksTable;

import org.apache.poi.openxml4j.util.ZipSecureFile;

import java.lang.reflect.Method;
import java.lang.reflect.InvocationTargetException;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Iterator;


public class ExternalLinksReader {

	private List<String> getLinkedWorkbooksHSSF(HSSFWorkbook workbook) {
		List<String> result = new ArrayList<>();
		try {
			// this is a hack to fetch linked workbooks in the Old Excel format
			// we use reflection to access private fields
			// might not work if internal structure of the class changes
			InternalWorkbook intWb = workbook.getInternalWorkbook();
			// method to fetch link table
			Method linkTableMethod = InternalWorkbook.class.getDeclaredMethod("getOrCreateLinkTable");
				linkTableMethod.setAccessible(true);
				Object linkTable = linkTableMethod.invoke(intWb);
			// method to fetch external book and sheet name
				Method externalBooksMethod = linkTable.getClass().getDeclaredMethod("getExternalBookAndSheetName", int.class);
				externalBooksMethod.setAccessible(true);
			// now we need to browse through the table until we hit an array out of bounds
			int i = 0;
			try {
				while(i<100) {
					String[] externalBooks = (String[])externalBooksMethod.invoke(linkTable, i++);
					if ((externalBooks!=null) && (externalBooks.length>0)){
						result.add(externalBooks[0]);
					}
					}
			} catch  ( java.lang.reflect.InvocationTargetException e) {
						 if ( !(e.getCause() instanceof java.lang.IndexOutOfBoundsException) ) {
						throw e;
						}
			}
				
		} catch (NoSuchMethodException nsme) {
			System.out.println(nsme);
		}
		 catch (IllegalAccessException iae) {
			System.out.println(iae);
		}
		catch (InvocationTargetException ite) {
			System.out.println(ite);
		}
		return result;
	}

  private List<String> getLinks(String filename) throws IOException, FileNotFoundException {

    FileInputStream excelFile = new FileInputStream(new File(filename));
    Workbook workbook = WorkbookFactory.create(excelFile);
	ZipSecureFile.setMinInflateRatio(0.005);

		List<String> result = new ArrayList<>();
		if (workbook instanceof HSSFWorkbook) {
			result = getLinkedWorkbooksHSSF((HSSFWorkbook) workbook);
		} else if (workbook instanceof XSSFWorkbook) {
			// use its API
			for (ExternalLinksTable element: ((XSSFWorkbook) workbook).getExternalLinksTable()) {
				result.add(element.getLinkedFileName());
			}
		}
	workbook.close();
	excelFile.close();
    return(result);
  }
  
  public List<List<String>> getLinks(String[] filenames) {
	  List<List<String>> result = new ArrayList<List<String>>();
	  for (String filename : filenames) {
		  try {
			result.add(getLinks(filename));
		  } catch (Exception e) {
			  List<String> error = new ArrayList<String>();
			  error.add("ERROR: " + e.getMessage());
			result.add(error);
		  }
	  }
	  return(result);
  }
}