            # CIRCEE: The CIRCular Energy Economy model #

CIRCEE, a deterministic Dynamic General Equilibrium model, is augmented with material flow analysis with mass balance and has a one-way soft-link to the IAM WITCH model (Emmerling et al., 2016). The model evaluates how circular economy strategies and enablers, such as new business models and lifestyle changes, can advance circular economy and climate change mitigation goals. This model captures the trade-offs and synergies between different sustainability objectives. Additionally, there’s a version called « CIRCEE_LIFE » that soft-links CIRCEE in a two-way with the lifestyle model LIFE model (Pettifor et al., 2023). 

The repository is composed of the following files :

  - Run File : CIRCEE_RunFile.m
    
This file serves as the primary running file, allowing users to select various model versions. Specifically, they can choose between B2C and C2C sharing business models, as indicated in line 8 of the file: « modelType = ‘B2C’ ». Additionally, users can select different regions, such as Japan, and the EU27 coming in October and mainland China in 2026.

Currently, the user can only choose the scenario SSP2 among all available scenarios.  However, other SSP scenarios beyond SSP2 will be added next year. 

Furthermore, the model can only be run without any lifestyle changes (no soft-link with LIFE).The parameters related to lifestyle changes are referred to as « modifiers » and have a default value of 0 in the public version of the file. If users wish to incorporate lifestyle changes into CIRCEE (sufficiency, repair, and sharing lifestyles), they can request this feature at darius.corbier@cmcc.it.

To introduce specific exogenous or policy variables (varexo in CIRCEE_PF.mod) with a particular growth rate, users can follow the instructions in section 3.1.2. of "CIRCEE_RunFile.m". Alternatively, they can specify specific absolute values in "shock.csv" or in CIRCEE_PF.mod. If they desire a fully deterministic model with no error of anticipation, they can use "shock.csv". Conversely, if they want a deterministic setup with anticipation errors, they can include the line "@#include « CIRCEE_shocks.m »" in "CIRCEE_PF.mod". For further information of the shock structure, please refer to the Dynare manual book at https://www.dynare.org/. 

One piece of advice : avoid using too many shocks and to be cautious about the magnitude of the shocks or you will bump into infeasibilities and corner solutions. 

   - Model File : "CIRCEE_PF.mod"
  
This is the primary model file that contains the declarations of variables and parameters, as well as the main equations and FOCs of the model. For a comprehensive overview of the equations, please refer to the Appendix of Corbier et al. (2025). It’s important to note that the model’s equations have undergone slight modifications since Corbier et al. (2025). 
    
  - Steady State File : "CIRCEE_steadystatemodel.m"
  
This file manually solves the steady-state of the model. If you modify any equation in CIRCEE_PF.mod, you must also adjust the model’s resolution for the steady state in CIRCEE_steadystatemodel.m.

  - Calibration file : "calibration.csv"
  
This is the calibration file with the values for parameters, and exogenous variables at steady state. The baseline year is 2018. 
    
  - Shocks file : "shocks.csv"
  
This file contains the values of exogenous/policy variables that can be introduced into the system at any time in a deterministic set up with no anticipation erros. 

To run the model, users must download Dynare from https://www.dynare.org/. They can then use either Matlab (version 2023-2024) or GNU Octave to run the model. A new version will be available for Julia users in the coming months. If possible, I recommend using Matlab over GNU Octave. To run CIRCEE, users can call the file « CIRCEE_RunFile.m » from their Matlab or GNU Octave console. If you encounter any issues, please contact darius.corbier@cmcc.it. Also, any comments or suggestions for model development are more than welcomed. 

If you use CIRCEE, please cite:

- Corbier, D., Pettifor, H., Agnew, M., & Drouet, L. (2024). CIRCEE, the CIRCular Energy Economy model: Bridging    the gap between economic and industrial ecology concepts. Journal of Industrial Ecology, 28(6), 1996-2011.

- Corbier, D., Pettifor, H., Agnew, M., & Nagashima, M. (2025). Shaping sustainable consumption practices:          Changing consumers’ habits through lifestyle changes and Extended Producer Responsibility schemes. Resources,     Conservation and Recycling, 217, 108214.
