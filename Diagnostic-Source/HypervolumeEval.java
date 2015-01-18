/*Written by Dave Hadka */
import java.io.File;
import java.io.IOException;

import org.moeaframework.core.NondominatedPopulation;
import org.moeaframework.core.PopulationIO;
import org.moeaframework.core.indicator.Hypervolume;
import org.moeaframework.analysis.sensitivity.*;

public class HypervolumeEval {
	
	public static void main(String[] args) throws IOException {
		NondominatedPopulation refSet = new NondominatedPopulation(
				PopulationIO.readObjectives(new File(args[0])));
		
		System.out.println(new Hypervolume(
				new ProblemStub(refSet.get(0).getNumberOfObjectives()), refSet)
				.evaluate(refSet));
	}

}
