classdef test_seq_play <matlab.uitest.TestCase
% Test playing SEQ App

% azim j
% 2024--12--02

properties
    App
    test_file = "D:\HOME\MATLAB\data_analysis\_Myofbril_Code_Collection_2021\__CURRENT\_data_myofibrils\m1_20160419_100x.seq"
end

methods (TestMethodSetup)
    function launchApp(testCase)
        testCase.App = seq.seq_viewer;
        testCase.App.test_file = testCase.test_file;
    end
end

methods (Test)
    function testOpenSEQ(testCase)
        testCase.press(testCase.App.OpenSEQfileButton);
    end

    

end
end