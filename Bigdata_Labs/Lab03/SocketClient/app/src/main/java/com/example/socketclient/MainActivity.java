package com.example.socketclient;

import android.os.AsyncTask;
import android.os.Bundle;
import android.app.Activity;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintStream;
import java.net.Socket;
import java.net.UnknownHostException;

public class MainActivity extends Activity {
 
 TextView responseText;
 EditText sourceAddrs, srcPort,romoCommand;
 Button connect, clear,send;
 String command;
 Boolean peek=false;
 @Override
 protected void onCreate(Bundle savedInstanceState) {
  super.onCreate(savedInstanceState);
  setContentView(R.layout.activity_main);
  
  sourceAddrs = (EditText)findViewById(R.id.address);
  srcPort = (EditText)findViewById(R.id.port);
  connect = (Button)findViewById(R.id.connect);
  clear = (Button)findViewById(R.id.clear);
  responseText = (TextView)findViewById(R.id.response);
  send=(Button) findViewById(R.id.send);
  editText=(EditText)findViewById(R.id.cmd);


  send.setOnClickListener(new OnClickListener(){

		@Override
		public void onClick(View arg0) {
			command=romoCommand.getText().toString();
			peek=true;
		}
		  
	  });
  connect.setOnClickListener(connectOnClickListener);
  clear.setOnClickListener(new OnClickListener(){
   @Override
   public void onClick(View v) {
    romoCommand.setText("");
       srcPort.setText("");
       sourceAddrs.setText("");
   }});
 }
 OnClickListener connectOnClickListener =
   new OnClickListener(){

    @Override
    public void onClick(View arg0) {
     MyClientTask myClientTask = new MyClientTask(
       sourceAddrs.getText().toString(),
       Integer.parseInt(srcPort.getText().toString()));
     myClientTask.execute();
    }};


 public class MyClientTask extends AsyncTask<Void, Void, Void> {
  
    String dstAddress;
    int dstPort;
    String response = "";
  
    MyClientTask(String addr, int port){
     dstAddress = addr;
     dstPort = port;
    }
    @Override
	protected Void doInBackground(Void... arg0) {

		OutputStream outputStream;
		Socket socket = null;

		try {
			socket = new Socket(dstAddress, dstPort);
			outputStream = socket.getOutputStream();
			
            PrintStream printStream = new PrintStream(outputStream);
			
			while (true) {
				if(peek)
				{
					printStream.print(command);printStream.flush();
					peek=false;
				}
			}

		} catch (UnknownHostException uhe) {
			uhe.printStackTrace();
			response = "UnknownHostException: " + uhe.toString();
		} catch (IOException ioe) {
			ioe.printStackTrace();
			response = "IOException: " + ioe.toString();
		} finally {
			if (socket != null) {
				try {
					socket.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
		return null;
	}
    @Override
    protected void onPostExecute(Void result) {
     responseText.setText(response);
     super.onPostExecute(result);
    }
  
 }

}
